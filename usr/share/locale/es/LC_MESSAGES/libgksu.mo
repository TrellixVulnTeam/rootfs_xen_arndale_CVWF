��    =        S   �      8  �   9  �     y   �  F   @  �   �  L     �  `     .
     >
  �   U
     -  A   I  1   �     �  6   �  "        7     O  U   f  O   �          +  :   J  E   �     �  S   �     =  (   M  .   v  ,   �     �  	   �  
   �               (     :     P     d  	   �  ?   �  �   �  w   u  �   �  �   �  .   K  �   z  �         �          -     C  #   O  Y   s  6   �  ;     	   @     J     R     o  �  �  �   +  �     �   �  U   m  �   �  b   a    �     �     �  �   �  0   �  H     P   ]  -   �  G   �  !   $     F     e  c   �  J   �  -   3   '   a   T   �   t   �   )   S!  c   }!     �!  <   �!  @   6"  6   w"  #   �"     �"     �"     �"     #     #     /#  !   L#  M   n#     �#  ?   �#  �   	$  �   �$  �   c%  �   &  :   �&  �   '  �   �'  @   �(     �(     �(     �(  0   	)  �   :)  H   �)  H   *  	   d*     n*     v*     �*     '   1          *      4   2         
   8   :                #       $   =                          7   -             ,       	      <               ;                           !            "          6   3   +                     0       /   5   9               .   &             (       %   )       <b><big>Could not grab your keyboard.</big></b>

A malicious client may be eavesdropping on your session or you may have just clicked a menu or some application just decided to get focus.

Try again. <b><big>Could not grab your mouse.</big></b>

A malicious client may be eavesdropping on your session or you may have just clicked a menu or some application just decided to get focus.

Try again. <b><big>Enter the administrative password</big></b>

The application '%s' lets you modify essential parts of your system. <b><big>Enter the password of %s to run the application '%s'</big></b> <b><big>Enter your password to perform administrative tasks</big></b>

The application '%s' lets you modify essential parts of your system. <b><big>Enter your password to run the application '%s' as user %s</big></b> <b><big>Granted permissions without asking for password</big></b>

The '%s' program was started with the privileges of the %s user without the need to ask for a password, due to your system's authentication mechanism setup.

It is possible that you are being allowed to run specific programs as user %s without the need for a password, or that the password is cached.

This is not a problem report; it's simply a notification to make sure you are aware of this. <b>Behavior</b> <b>Screen Grabbing</b> <b>Would you like your screen to be "grabbed"
while you enter the password?</b>

This means all applications will be paused to avoid
the eavesdropping of your password by a a malicious
application while you type it. <b>You have capslock on</b> <span weight="bold" size="larger">Type the root password.</span>
 Configure behavior of the privilege-granting tool Disable keyboard and mouse grab Display information message when no password is needed Do _not display this message again Error creating pipe: %s Error opening pipe: %s Failed to communicate with gksu-run-helper.

Received bad string while expecting:
 %s Failed to communicate with gksu-run-helper.

Received:
 %s
While expecting:
 %s Failed to exec new process: %s Failed to fork new process: %s Failed to load glade file; please check your installation. Failed to obtain xauth key: xauth binary not found at usual locations Force keyboard and mouse grab Grab keyboard and mouse even if -g has been passed as argument on the command line. Granting Rights Keyring to which passwords will be saved Not using locking for nfs mounted lock file %s Not using locking for read only lock file %s Password prompt canceled. Password: Password:  Privilege granting Prompt for grabbing Remember password Save for this session Save in the keyring Save password to gnome-keyring Sudo mode The gksu-run-helper command was not found or is not executable. The name of the keyring gksu should use. Usual values are "session", which saves the password for the session, and "default", which saves the password with no timeout. The underlying authorization mechanism (sudo) does not allow you to run this program. Contact the system administrator. This option determines whether a message dialog will be displayed informing the user that the program is being run without the need of a password being asked for some reason. This option will make gksu prompt the user if he wants to have the screen grabbed before entering the password. Notice that this only has an effect if force-grab is disabled. Unable to copy the user's Xauthorization file. Whether sudo should be the default backend method. This method is otherwise accessed though the -S switch or by running 'gksudo' instead of 'gksu'. Whether the keyboard and mouse grabbing should be turned off. This will make it possible for other X applications to listen to keyboard input events, thus making it not possible to shield from malicious applications which may be running. Wrong password got from keyring. Wrong password. _Authentication mode: _Grab mode: enable
disable
force enable
prompt
 gksu can save the password you type to the gnome-keyring so you'll not be asked everytime gksu_run needs a command to be run, none was provided. gksu_sudo_run needs a command to be run, none was provided. gtk-close su
sudo su terminated with %d status sudo terminated with %d status Project-Id-Version: libgksu 2.0.9
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2009-01-27 09:23+0700
PO-Revision-Date: 2009-03-22 14:00+0100
Last-Translator: Francisco Javier Cuadrado <fcocuadrado@gmail.com>
Language-Team: Debian l10n Spanish <debian-l10n-spanish@lists.debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Plural-Forms: nplurals=2; plural=(n != 1);
 <b><big>No se pudo bloquear su teclado.</big></b>

Un cliente malicioso quizá esté espiando su sesión o quizá acaba de pulsar en un menú o alguna aplicación que acaba de decidir obtener el foco.

Intente de nuevo. <b><big>No se pudo bloquear su ratón.</big></b>

Un cliente malicioso quizá esté espiando su sesión o quizá acaba de pulsar en un menú o alguna aplicación que acaba de decidir obtener el foco.

Intente de nuevo. <b><big>Introduzca la contraseña del administrador</big></b>

La aplicación «%s» le permite modificar partes esenciales de su sistema. <b><big>Introduzca la contraseña de %s para ejecutar la aplicación «%s»</big></b> <b><big>Introduzca su contraseña para realizar tareas administrativas</big></b>

La aplicación «%s» le permite modificar partes esenciales de su sistema. <b><big>Introduzca su contraseña para ejecutar la aplicación «%s» como el usuario %s</big></b> <b><big>Se han concedido permisos sin pedir una contraseña</big></b>

El programa «%s» se ha iniciado con los privilegios del usuario %s sin necesidad de pedir una contraseña, debido a la configuración del mecanismo de autenticación de su sistema.

Es posible que se le permita ejecutar programas específicos como el usuario %s sin necesidad de una contraseña, o que la contraseña está cacheada.

Esto no es un informe de un problema, sino una notificación para asegurarse de que es consciente de esto. <b>Comportamiento</b> <b>Bloqueando la pantalla</b> <b>¿Quiere que su pantalla sea «bloqueada»
cuando introduzca su contraseña?</b>

Esto significa que todas las aplicaciones se pausarán
para evitar el espionaje de su contraseña por una aplicación
maliciosa mientras la teclea. <b>Tiene pulsada la tecla de Bloqueo Mayús.</b> <span weight="bold" size="larger">Teclee la contraseña de root.</span>
 Configurar el comportamiento de la herramienta para la obtención de privilegios Desactivar el bloqueo del teclado y el ratón Mostrar el mensaje de información cuando no se necesite la contraseña _No mostrar este mensaje de nuevo Error al crear la tubería: %s Error al abrir la tubería: %s Falló al comunicar con gksu-run-helper.

Se recibió una cadena errónea mientras se esperaba:
 %s No se puedo comunicar con gksu-run-helper.

Recibido:
 %s
Se esperaba:
 %s Falló al efectuar exec del proceso nuevo: %s Falló al bifurcar el proceso nuevo: %s Se produjo un fallo al cargar el archivo glade, por favor compruebe la instalación. Se produjo un fallo al obtener la clave de xauth: el binario de xauth no se ha encontrado en las ubicaciones usuales Forzar el bloqueo del teclado y el ratón Bloquear el teclado y el ratón incluso si se ha pasado la opción «-g» en la línea de órdenes. Concediendo privilegios Depósito de claves en el que se guardarán las contraseñas Sin uso de bloqueo para el archivo de bloqueo montado por nfs %s Sin uso de bloqueo para el archivo de sólo lectura %s Petición de contraseña cancelada. Contraseña: Contraseña:  Obteniendo privilegios Preguntar al bloquear Recordar contraseña Guardar durante esta sesión Guardar en el depósito de claves Guardar la contraseña en el depósito de claves de GNOME («gnome-keyring») Modo de sudo No se encontró la orden de gksu-run-helper o no es ejecutable. El nombre del depósito de claves que debería utilizar gksu. Los valores usuales son «sesión», que guarda la contraseña durante la sesión, y «predeterminado», que guarda la contraseña sin fecha de caducidad. El mecanismo de autorización subyacente (sudo) no le permite ejecutar este programa. Contacte con su administrador de sistemas. Esta opción determina si un diálogo de mensajes se mostrará informando al usuario de que el programa se está ejecutando sin necesidad de pedirle una contraseña por alguna razón. Esta opción hará que gksu pregunte al usuario si quiere tener la pantalla bloqueada antes de introducir la contraseña. Tenga en cuenta que esto sólo tiene efecto si no fuerza el bloqueo. No es posible copiar el archivo Xautorization del usuario. Cuando sudo sea el método predeterminado, a este método se accederá mediante el parámetro «-S» o ejecutando «gksudo» en lugar de «gksu». Si el bloqueo del teclado y el ratón esté desactivado, otras aplicaciones de X podrán escuchar los eventos de entrada del teclado, incluso no pudiendo protegerse de aplicaciones malignas que pueden estar ejecutándose. Se ha obtenido una contraseña errónea del depósito de claves. Contraseña errónea. Modo de _autenticación: Modo del _bloqueo: activar
desactivar
forzar activación
preguntar
 gksu puede guardar la contraseña que ha escrito en el depósito de claves de GNOME («gnome-keyring»). de modo que no se le pregunte siempre por ella gksu_run necesita una orden a ejecutar, pero no se proporcionó ninguna. gksu_sudo_run necesita una orden a ejecutar, no se proporcionó ninguna. gtk-close su
sudo su terminó con el estado %d sudo terminó con el estado %d 