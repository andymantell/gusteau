/// The model's tool-use call, extracted from a Bedrock Converse response.
class ToolUseCall {
  const ToolUseCall({
    required this.toolUseId,
    required this.toolName,
    required this.input,
  });

  final String toolUseId;
  final String toolName;
  final Map<String, dynamic> input;
}

/// The response didn't contain a usable tool-use call — the model
/// declined to call the tool, stopped early, or the shape was
/// otherwise not what Bedrock's Converse API is documented to return.
/// Real and worth seeing, not a null-check crash. See
/// docs/planning/architecture.md, "Error handling".
class ConverseResponseException implements Exception {
  ConverseResponseException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Extracts the model's tool-use call from a decoded Bedrock Converse
/// response body (`output.message.content[]`, looking for the entry
/// with a `toolUse` key). Throws [ConverseResponseException] if none
/// is found.
ToolUseCall extractToolUseCall(Map<String, dynamic> converseResponse) {
  final stopReason = converseResponse['stopReason'];
  final output = converseResponse['output'];
  final message = output is Map ? output['message'] : null;
  final content = message is Map ? message['content'] : null;

  if (content is! List) {
    throw ConverseResponseException(
      'no message content in Bedrock response (stopReason: $stopReason)',
    );
  }

  for (final block in content) {
    if (block is Map && block['toolUse'] is Map) {
      final toolUse = (block['toolUse'] as Map).cast<String, dynamic>();
      final toolUseId = toolUse['toolUseId'];
      final toolName = toolUse['name'];
      final input = toolUse['input'];
      if (toolUseId is! String || toolName is! String || input is! Map) {
        throw ConverseResponseException(
          'malformed toolUse block in Bedrock response: $toolUse',
        );
      }
      return ToolUseCall(
        toolUseId: toolUseId,
        toolName: toolName,
        input: input.cast<String, dynamic>(),
      );
    }
  }

  throw ConverseResponseException(
    'model did not call a tool (stopReason: $stopReason)',
  );
}
