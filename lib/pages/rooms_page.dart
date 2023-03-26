// Importa los paquetes necesarios de Flutter y Flutter Bloc
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart';

import '../cubits/profiles/profiles_cubit.dart';
import '../cubits/rooms/rooms_cubit.dart';
import '../models/profile.dart';
import '../pages/chat_page.dart';
import '../pages/register_page.dart';
import '../utils/constants.dart';

/// Muestra la lista de hilos de chat
class RoomsPage extends StatelessWidget {
  const RoomsPage({Key? key}) : super(key: key);

// Define la ruta de la página
  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => BlocProvider<RoomCubit>(
// Crea una instancia del cubit de salas de chat y lo inicializa
        create: (context) => RoomCubit()..initializeRooms(context),
        child: const RoomsPage(),
      ),
    );
  }

  // Método encargado de construir la página
  @override
  Widget build(BuildContext context) {
// Crea un Scaffold que contiene la barra de navegación y el cuerpo de la página
    return Scaffold(
      appBar: AppBar(
// Define el título de la barra de navegación
        title: const Text('Rooms'),
// Define los botones de acción de la barra de navegación
        actions: [
          TextButton(
            onPressed: () async {
// Al presionar el botón de logout, cierra sesión y redirige a la página de registro
              await supabase.auth.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                RegisterPage.route(),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
// El cuerpo de la página es construido utilizando un BlocBuilder del cubit de salas de chat
      body: BlocBuilder<RoomCubit, RoomState>(
        builder: (context, state) {
// Si el estado es de carga, muestra un preloader
          if (state is RoomsLoading) {
            return preloader;
          }
// Si el estado es que las salas fueron cargadas, muestra la lista de salas
          else if (state is RoomsLoaded) {
// Obtiene los nuevos usuarios y las salas de chat del estado
            final newUsers = state.newUsers;
            final rooms = state.rooms;
// Construye la lista de salas de chat utilizando un BlocBuilder del cubit de perfiles
            return BlocBuilder<ProfilesCubit, ProfilesState>(
              builder: (context, state) {
                if (state is ProfilesLoaded) {
// Obtiene los perfiles de usuario
                  final profiles = state.profiles;
// Construye la lista de salas de chat
                  return Row(
                    children: [
                      _NewUsers(newUsers: newUsers),
                      Expanded(
                        child: ListView.builder(
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
// Obtiene la sala y el perfil del usuario con el que se está chateando
                            final room = rooms[index];
                            final otherUser = profiles[room.otherUserId];

                            // Construye un listado de salas de chat
                            return ListTile(
// Al hacer clic en la 7774sala de chat, redirige a la página de chat correspondiente
                              onTap: () => Navigator.of(context)
                                  .push(ChatPage.route(room.id)),
// Muestra el avatar del usuario con el que se está chateando
                              leading: CircleAvatar(
                                child: otherUser == null
                                    ? preloader
                                    : Text(otherUser.username.substring(0, 2)),
                              ),
// Muestra el nombre del usuario con el que se está chateando
                              title: Text(otherUser == null
                                  ? 'Loading...'
                                  : otherUser.username),
// Muestra el último mensaje enviado en la sala de chat
                              subtitle: room.lastMessage != null
                                  ? Text(
                                      room.lastMessage!.content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : const Text('Room created'),
// Muestra la fecha y hora del último mensaje enviado en la sala de chat
                              trailing: Text(format(
                                  room.lastMessage?.createdAt ?? room.createdAt,
                                  locale: 'en_short')),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
// Si el estado del cubit de perfiles no es ProfilesLoaded, muestra un preloader
                else {
                  return preloader;
                }
              },
            );
          }
// Si el estado del cubit de salas de chat es RoomsEmpty, muestra una columna con los nuevos usuarios y un mensaje indicando cómo comenzar una conversación
          else if (state is RoomsEmpty) {
            final newUsers = state.newUsers;
            return Row(
              children: [
                _NewUsers(newUsers: newUsers),
                const Expanded(
                  child: Center(
                    child: Text('Start a chat by tapping on available users'),
                  ),
                ),
              ],
            );
          }
// Si el estado del cubit de salas de chat es RoomsError, muestra un mensaje de error
          else if (state is RoomsError) {
            return Center(child: Text(state.message));
          }

          // Línea que lanza una excepción para indicar que la funcionalidad no ha sido implementada
          throw UnimplementedError();
        },
      ),
    );
  }
}

// Clase que crea un widget para mostrar una lista de nuevos usuarios
class _NewUsers extends StatelessWidget {
  const _NewUsers({
    Key? key,
    required this.newUsers,
  }) : super(key: key);

  final List<Profile> newUsers;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: Row(
        children: [
          SingleChildScrollView(
            // Espaciado vertical de 8 píxeles
            padding: const EdgeInsets.symmetric(vertical: 8),
            // Dirección de desplazamiento horizontal
            scrollDirection: Axis.vertical,
            child: Column(
              children: newUsers
                  .map<Widget>((user) => InkWell(
                        onTap: () async {
                          try {
                            // Crea una sala y obtiene su ID
                            final roomId =
                                await BlocProvider.of<RoomCubit>(context)
                                    .createRoom(user.id);
                            // Navega a la pantalla de chat de la sala recién creada
                            Navigator.of(context).push(ChatPage.route(roomId));
                          } catch (_) {
                            // Muestra una notificación de error en caso de que falle la creación de la sala
                            context.showErrorSnackBar(
                                message: 'Failed creating a new room');
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 60,
                            child: Column(
                              children: [
                                // Avatar circular con las iniciales del usuario
                                CircleAvatar(
                                  child: Text(user.username.substring(0, 2)),
                                ),
                                const SizedBox(height: 8),
                                // Nombre de usuario con un máximo de una línea y texto truncado con puntos suspensivos en caso de desbordamiento
                                Text(
                                  user.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ), //jppkp
        ],
      ),
    );
  }
}
