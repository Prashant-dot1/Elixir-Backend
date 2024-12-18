defmodule BackendServer.Shader do
  # @api_url Application.get_env(:backend_server, :openai)[:api_url] || "https://api.openai.com/v1/chat/completions"
  # @api_key Application.get_env(:backend_server, :openai)[:api_key]

  # api_url = Application.get_env(:backend_server, :openai)[:api_url]
  # api_key = Application.get_env(:backend_server, :openai)[:api_key]

  def generate_shader(description) do
    body = Jason.encode!(%{
      model: "gpt-4",
      messages: [
        %{"role" => "system", "content" => "You are an expert in generating WebGL shaders and geometry."},
        %{"role" => "user", "content" => build_prompt(description)}
      ],
      max_tokens: 700,
      temperature: 0.7
    })

    headers = [
      {"Authorization", "Bearer #{api_key()}"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(api_url(), body, headers, timeout: 30_000, recv_timeout: 30_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        response = Jason.decode!(response_body)
        content = response["choices"] |> List.first() |> Map.get("message") |> Map.get("content")
        parse_shader_response(content)

      {:ok, %HTTPoison.Response{status_code: status_code, body: error_body}} ->
        {:error, "API Error #{status_code}: #{error_body}"}

      {:error, reason} ->
        {:error, "Failed to contact LLM: #{inspect(reason)}"}
    end
  end

  defp api_url do
    Application.fetch_env!(:backend_server, :openai)[:api_url] || "https://api.openai.com/v1/chat/completions"
  end

  defp api_key do
    Application.fetch_env!(:backend_server, :openai)[:api_key] ||
      raise "OPENAI_API_KEY is missing. Please set it in the environment."
  end

  defp build_prompt(description) do
    """
    Generate a WebGL-compatible GLSL shader and geometry in strict JSON format based on the following description:

    "#{description}"

    Requirements:
    1. Ensure the number of vertices in the "vertices" array matches the highest index used in the "indices" array.
    2. Each vertex position in the "vertices" array must align with the attribute definition in the vertex shader.
        - If the attribute is 'vec3', provide 3 components per vertex.
        - If the attribute is 'vec4', provide 4 components per vertex.
    3. Return only raw JSON without any explanation, text, or code block formatting.
    - JSON structure:
        - "vertexShaderCode": A string containing the vertex shader code. Please note : This should have the position attribute - "position"
        - "fragmentShaderCode": A string containing the fragment shader code.
        - "uniforms": An array of uniforms with name, type, and description.
        - "vertices": An array of vertex positions (floats).
        - "indices": An array of indices for drawing triangles.
        - "drawMode": A string specifying the WebGL-compatible draw mode (e.g., "TRIANGLES").
      - Ensure the number of vertices in the vertices array matches the highest index used in the indices array.
      - Do not include comments, extra text, or markdown formatting in the response.

    """
  end

  defp parse_shader_response(response_text) do
    IO.puts("Raw LLM Response:")
    IO.inspect(response_text)

    # Clean response: Extract JSON content
    json_block =
      response_text
      |> String.replace(~r/```json|```/i, "")  # Remove markdown JSON code block markers
      |> String.trim()                        # Remove leading/trailing whitespace

    IO.puts("Cleaned JSON Block:")
    IO.inspect(json_block)

    # Attempt to decode JSON
    case Jason.decode(json_block) do
      {:ok, shader_data} ->
        IO.puts("Decoded Shader Data:")
        IO.inspect(shader_data)
        {:ok, shader_data}

      {:error, reason} ->
        IO.puts("JSON Decode Error:")
        IO.inspect(reason)
        {:error, "Failed to parse shader response. Ensure LLM output is valid JSON."}
    end
  rescue
    _ -> {:error, "Unexpected error while parsing shader response."}
  end
end
