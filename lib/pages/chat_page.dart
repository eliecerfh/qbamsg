// Importamos los paquetes necesarios
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../components/user_avatar.dart';
import '../cubits/chat/chat_cubit.dart';
import '../models/message.dart';
import '../utils/constants.dart';
import 'package:timeago/timeago.dart';

// Creamos la clase ChatPage que extiende de StatelessWidget
class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

// Creamos una función estática route que devuelve una nueva instancia de MaterialPageRoute
  static Route<void> route(String roomId) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<ChatCubit>(
        create: (context) => ChatCubit()..setMessagesListener(roomId),
        child: const ChatPage(),
      ),
    );
  }

// Implementamos el método build que devuelve un Scaffold
  @override
  Widget build(BuildContext context) {
    return Scaffold(
// Definimos la appBar
      appBar: AppBar(title: const Text('Chat')),
// Definimos el body como un BlocConsumer
      body: BlocConsumer<ChatCubit, ChatState>(
// Implementamos el listener para manejar los errores
        listener: (context, state) {
          if (state is ChatError) {
            context.showErrorSnackBar(message: state.message);
          }
        },
// Implementamos el builder para construir la UI en función del estado
        builder: (context, state) {
          if (state is ChatInitial) {
            return preloader;
          } else if (state is ChatLoaded) {
            final messages = state.messages;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _ChatBubble(message: message);
                    },
                  ),
                ),
                const _MessageBar(),
              ],
            );
          } else if (state is ChatEmpty) {
            return Column(
              children: const [
                Expanded(
                  child: Center(
                    child: Text('Start your conversation now :)'),
                  ),
                ),
                _MessageBar(),
              ],
            );
          } else if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          throw UnimplementedError();
        },
      ),
    );
  }
}

// Creamos la clase _MessageBar que extiende de StatefulWidget
class _MessageBar extends StatefulWidget {
  const _MessageBar({
    Key? key,
  }) : super(key: key);

// Implementamos el método createState que devuelve una nueva instancia de _MessageBarState
  @override
  State<_MessageBar> createState() => _MessageBarState();
}

// Creamos la clase _MessageBarState que extiende de State<_MessageBar>
class _MessageBarState extends State<_MessageBar> {
  late final TextEditingController _textController;

// Implementamos el método build que devuelve un Material con un TextFormField y un TextButton
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.text,
                maxLines: null,
                autofocus: true,
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            TextButton(
              onPressed: () => _submitMessage(),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

// Implementamos el método initState para inicializar el _textController
  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

// Implementamos el método dispose para liberar los recursos del _textController
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

// Implementamos el método _submitMessage para enviar el mensaje
  void _submitMessage() async {
    final text = _textController.text;
    if (text.isEmpty) {
      return;
    }
    BlocProvider.of<ChatCubit>(context).sendMessage(text);
    _textController.clear();
  }
}

// Creamos la clase _ChatBubble que extiende de StatelessWidget
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);
// Definimos las propiedades de la clase _ChatBubble y construimos su UI
  final Message message;

  @override
  Widget build(BuildContext context) {
    List<Widget> chatContents = [
      if (!message.isMine) UserAvatar(userId: message.profileId),
      const SizedBox(width: 12),
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: message.isMine
                ? Colors.redAccent
                : Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.content),
        ),
      ),
      const SizedBox(width: 12),
      Text(format(message.createdAt, locale: 'en_short')),
      const SizedBox(width: 60),
    ];
    if (message.isMine) {
      chatContents = chatContents.reversed.toList();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: chatContents,
      ),
    );
  }
}
