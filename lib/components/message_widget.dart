import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageWidget extends StatelessWidget {
  final String message;
  final bool isAIMessage;

  const MessageWidget({
    Key? key,
    required this.message,
    required this.isAIMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageText = isAIMessage ? message.substring(4) : message;

    return Align(
      alignment: isAIMessage ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(
          left: isAIMessage ? 8.0 : 64.0,
          right: isAIMessage ? 64.0 : 8.0,
          top: 4.0,
          bottom: 4.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isAIMessage
                ? theme.colorScheme.surfaceVariant.withOpacity(0.8)
                : theme.colorScheme.primaryContainer.withOpacity(0.9),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isAIMessage ? 8 : 16),
              topRight: Radius.circular(isAIMessage ? 16 : 8),
              bottomLeft: const Radius.circular(16),
              bottomRight: const Radius.circular(16),
            ),
            border: Border.all(
              color: isAIMessage
                  ? theme.colorScheme.surfaceVariant
                  : theme.colorScheme.primaryContainer,
              width: 1,
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: SelectableRegion(
              focusNode: FocusNode(),
              selectionControls: MaterialTextSelectionControls(),
              child: isAIMessage
                  ? MarkdownBody(
                      data: messageText,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Text(
                      messageText,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
