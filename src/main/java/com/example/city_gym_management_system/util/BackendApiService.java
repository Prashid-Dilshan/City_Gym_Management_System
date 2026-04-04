package com.example.city_gym_management_system.util;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.ServletContext;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

public class BackendApiService {

    private static final String DEFAULT_BASE_URL = "http://localhost:8081";

    private final HttpClient client;
    private final String baseUrl;

    public BackendApiService(ServletContext context) {
        this.client = HttpClient.newHttpClient();
        String configuredBaseUrl = context.getInitParameter("backend.base.url");
        this.baseUrl = configuredBaseUrl == null || configuredBaseUrl.isBlank() ? DEFAULT_BASE_URL : configuredBaseUrl;
    }

    public JsonArray getArray(String pathAndQuery) throws IOException, InterruptedException {
        HttpResponse<String> response = send("GET", pathAndQuery, null);
        ensureSuccess(response);
        return JsonParser.parseString(response.body()).getAsJsonArray();
    }

    public JsonObject getObject(String pathAndQuery) throws IOException, InterruptedException {
        HttpResponse<String> response = send("GET", pathAndQuery, null);
        ensureSuccess(response);
        return JsonParser.parseString(response.body()).getAsJsonObject();
    }

    public JsonObject postJson(String pathAndQuery, JsonObject body) throws IOException, InterruptedException {
        HttpResponse<String> response = send("POST", pathAndQuery, body == null ? "{}" : body.toString());
        ensureSuccess(response);
        return response.body() == null || response.body().isBlank()
                ? new JsonObject()
                : JsonParser.parseString(response.body()).getAsJsonObject();
    }

    public JsonObject putJson(String pathAndQuery, JsonObject body) throws IOException, InterruptedException {
        HttpResponse<String> response = send("PUT", pathAndQuery, body == null ? "{}" : body.toString());
        ensureSuccess(response);
        return response.body() == null || response.body().isBlank()
                ? new JsonObject()
                : JsonParser.parseString(response.body()).getAsJsonObject();
    }

    public void delete(String pathAndQuery) throws IOException, InterruptedException {
        HttpResponse<String> response = send("DELETE", pathAndQuery, null);
        ensureSuccess(response);
    }

    public static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private HttpResponse<String> send(String method, String pathAndQuery, String body) throws IOException, InterruptedException {
        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + pathAndQuery))
                .header("Accept", "application/json");

        if ("POST".equals(method) || "PUT".equals(method)) {
            builder.header("Content-Type", "application/json")
                    .method(method, HttpRequest.BodyPublishers.ofString(body));
        } else {
            builder.method(method, HttpRequest.BodyPublishers.noBody());
        }

        return client.send(builder.build(), HttpResponse.BodyHandlers.ofString());
    }

    private void ensureSuccess(HttpResponse<String> response) throws IOException {
        if (response.statusCode() < 200 || response.statusCode() >= 300) {
            throw new IOException("Backend API request failed with status " + response.statusCode());
        }
    }
}
