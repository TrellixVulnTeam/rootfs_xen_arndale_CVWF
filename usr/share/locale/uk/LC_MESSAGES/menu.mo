��    E      D  a   l      �  !   �          2  4   C     x     �  %   �     �  #   �       '   &  "   N  "   q  +   �     �     �  :   �     .  ;   =  *   y     �  >   �  �   �  /   �	  '   �	  2   �	  >   
  "   ]
     �
      �
     �
     �
     �
                <  #   Z  #   ~     �     �     �     �     	     !     ;     U     d     {  H   �  !   �     �  ;    A   X  A   �  9   �  %     ?   <  6  |  D   �  2   �     +  P   G  #   �  $   �  %   �  *     .   2  T   a  _  �  ?     <   V  8   �  {   �  0   H  W   y  ?   �  2     P   D  H   �  o   �  7   N  6   �  N   �  K     )   X  e   �     �  ~     i   �  0   �  s   !    �  W   �  ]   �  P   T  q   �  H      A   `   ;   �   $   �      !  &   !!     H!  >   `!  3   �!  7   �!  7   "  )   C"  7   m"  /   �"  1   �"  1   #  K   9#  <   �#      �#  )   �#  7   $     E$  ?   �$  6   %  �  <%  �   �)  t   ^*  P   �*  d   $+  w   �+  �  ,  r   �-  O   >.  .   �.  �   �.  (   P/  3   y/  4   �/  2   �/  F   0  s   \0     &   @                  1   0      6                    >             C                         -   =   B      5       ,           (          ?   2   #   A   4           9      '          *      E   +   7          /       	         %   !   ;      :         $                                 3       
       )   8                      "          <   D   .    %1 menu entries found (%2 total). %1: missing required tag: "%2" (probably) stdin Boolean (either true or false) expected.
Found: "%1" Cannot create pipe. Cannot lock %1: %2 - Aborting. Cannot open file %1 (also tried %2).
 Cannot open file %1.
 Cannot open script %1 for reading.
 Cannot remove lockfile %1. Cannot write to lockfile %1 - Aborting. Could not change directory(%1): %2 Could not create directory(%1): %2 Dpkg is not locking dpkg status area, good. Encoding conversion error: "%1" Error reading %1.
 Execution of %1 generated no output or returned an error.
 Expected: "%1" Failed to pipe data through "%1" (pipe opened for reading). Further output (if any) will appear in %1. Identifier expected. In file "%1", at (or in the definition that ends at) line %2:
 In order to be able to create the user config file(s) for the window manager,
the above file needs to be writeable (and/or the directory needs to exist).
 Indirectly used, but not defined function: "%1" Menu entry lacks mandatory field "%1".
 Number of arguments to function %1 does not match. Other update-menus processes are already locking %1, quitting. Reading installed packages list... Reading menu-entry files in %1. Reading translation rules in %1. Running menu-methods in %1. Running method: %1 Running method: %1 --remove Running: "%1"
 Script %1 could not be executed. Script %1 received signal %2. Script %1 returned error status %2. Skipping file because of errors...
 Somewhere in input file:
 Unable to open file "%1". Unexpected character: "%1" Unexpected end of file. Unexpected end of line. Unknown compat mode: "%1" Unknown error, message=%1 Unknown error. Unknown function: "%1" Unknown identifier: "%1" Unknown install condition "%1" (currently, only "package" is supported). Unknown value for field %1="%2".
 Update-menus is run by user. Usage: update-menus [options] 
Gather packages data from the menu database and generate menus for
all programs providing menu-methods, usually window-managers.
  -d                     Output debugging messages.
  -v                     Be verbose about what is going on.
  -h, --help             This message.
  --menufilesdir=<dir>   Add <dir> to the lists of menu directories to search.
  --menumethod=<method>  Run only the menu method <method>.
  --nodefaultdirs        Disable the use of all the standard menu directories.
  --nodpkgcheck          Do not check if packages are installed.
  --remove               Remove generated menus instead.
  --stdout               Output menu list in format suitable for piping to
                         install-menu.
  --version              Output version information and exit.
 Waiting for dpkg to finish (forking to background).
(checking %1) Warning: script %1 does not provide removemenu, menu not deleted
 Warning: the string %1 did not occur in template file %2
 Zero-size argument to print function. file %1 line %2:
Discarding entry requiring missing package %3. install-menu [-vh] <menu-method>
  Read menu entries from stdin in "update-menus --stdout" format
  and generate menu files using the specified menu-method.
  Options to install-menu:
     -h --help    : this message
        --remove  : remove the menu instead of generating it.
     -v --verbose : be verbose
 install-menu: "hotkeycase" can only be "sensitive" or "insensitive"
 install-menu: %1 must be defined in menu-method %2 install-menu: %1: aborting
 install-menu: Warning: Unknown identifier `%1' on line %2 in file %3. Ignoring.
 install-menu: [supported]: name=%1
 install-menu: checking directory %1
 install-menu: creating directory %1:
 install-menu: directory %1 already exists
 install-menu: no menu-method script specified! replacewith($string, $replace, $with): $replace and $with must have the same length. Project-Id-Version: menu 2.1.37
Report-Msgid-Bugs-To: menu@packages.debian.org
POT-Creation-Date: 2007-10-05 07:30+0200
PO-Revision-Date: 2011-03-11 12:08+0300
Last-Translator: Serhij Dubyk <serhijdubyk@gmail.com>
Language-Team: Ukrainian Linux Team <translation@linux.org.ua>
Language: 
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Generator: KBabel 1.11.4
Plural-Forms: nplurals=3; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2);
X-Poedit-Language: Ukrainian
X-Poedit-Country: UKRAINE
X-Poedit-SourceCharset: utf-8
 Знайдено пунктів меню: %1 (усього %2). %1: відсутня необхідна мітка: „%2“ (можливо) stdin (стандартний ввід) Очікується логічне значення (або „true“, або ж „false“).
Знайдено: „%1“ Не вдалося створити канал. Неможливо заблокувати %1: %2 — скасування роботи. Не вдалося відкрити файл %1 (як і %2).
 Не вдалося відкрити файл %1.
 Не вдалося відкрити сценарій %1 для читання.
 Не вдається вилучити файл блокування %1. Не вдалося записати у файл блокування %1 — скасування роботи. Не вдалося перейти у теку (%1): %2 Не вдалося створити теку (%1): %2 Dpkg не блокує область статусу, це нормально. Помилка при перетворенні кодування: „%1“ Помилка при читанні %1.
 Виконання %1 завершилося без результату або з помилкою.
 Очікується: „%1“ Помилка передачі даних через канал „%1“ (канал відкритий на читання). Подальший вивід (якщо такий буде) буде перенаправлено у %1. Очікується ідентифікатор. У файлі „%1“, у рядку (або у визначенні, яке закінчується тут) %2:
 Щоб створювати власні конфігураційні файли для менеджера вікон,
вищевказані файли повинні бути доступні на запис (та/чи теки повинні існувати).
 Неявне використання невизначеної функції: „%1“ У записі пункту меню відсутнє необхідне поле „%1“.
 Неправильне число аргументів для функції %1. Вже запущені інші процеси „update-menu“, що блокують %1, отож вихід. Читання списку встановлених пакунків… Читання файлів для пунктів меню з %1. Читання правил перетворення у %1. Запуск menu-method-ів з %1. Запуск методу: %1 Запуск методу: %1 --remove Запуск: „%1“
 Сценарій %1 не може бути виконаний. Сценарій %1 отримав сигнал %2. Сценарій %1 повернув помилку %2. Пропуск файлу через помилки…
 Десь у вхідному файлі:
 Не вдалося відкрити файл „%1“. Несподіваний символ: „%1“ Несподіваний кінець файлу. Несподіваний кінець рядка. Невідомий режим сумісності („compat“): „%1“ Невідома помилка, повідомлення=%1 Невідома помилка. Невідома функція: „%1“ Невідомий ідентифікатор: „%1“ Невідома умова встановлення „%1“ (наразі підтримується лише „package“). Невідоме значення для поля %1=„%2“.
 update-menu запущено користувачем. Використання: update-menus [опції]
Збирає дані про пакунки з бази даних меню та генерує меню для
усіх програм, які надають menu-method-и, зазвичай це менеджери вікон.
 -d   Виводити повідомлення налагодження.
 -v   Докладно повідомляти що відбувається при роботі.
 -h, --help   Це повідомлення.
 --menufilesdir=<тека>  Додати <теку> до списку пошуку тек меню.
 --menumethod=<метод>  Виконати лише вказаний <метод>-меню.
 --nodefaultdirs   Не використовувати стандартні теки меню.
 --nodpkgcheck   Не перевіряти, чи встановлені пакунки.
 --remove  Вилучати, а не створювати меню.
 --stdout  Виведення списку меню у форматі, придатному для передачі
  по каналу в install-menu.
 --version  Показати версію та завершити роботу.
 Очікується завершення роботи „dpkg“ (робота у фоновому режимі).
(перевірка %1) Увага: сценарій %1 не містить функції „removemenu“, меню не вилучено
 Увага: рядок %1 не знайдено у файлі шаблону %2
 У функцію „print“ переданий аргумент нульового розміру. файл %1, рядок %2:
Вилучається, запис вимагає відсутнього пакунка %3. install-menu [-vh] <menu-method>
 Читає записи пунктів меню з stdin у форматі „update-menus -- stdout“
 та генерує файли меню, використовуючи зазначений menu-method.
 Параметри install-menu:
 -h --help: це повідомлення
 --remove: вилучити меню, а не створювати.
 -v --verbose: видавати докладну інформацію
 install-menu: „hotkeycase“ може мати значення лише „sensitive“ чи „insensitive“
 install-menu: %1 повинен бути визначений у menu-method %2 install-menu: %1: скасування дії
 install-menu: Увага: невідомий ідентифікатор „%1“ у рядку %2 з файлу „%3“. Ігнорується.
 install-menu: [supported]: ім’я=%1
 install-menu: перевірка теки „%1“
 install-menu: створення теки „%1“:
 install-menu: тека „%1“ вже існує
 install-menu: не вказано сценарій для menu-method! replacewith($string, $replace, $with): $replace та $with повинні мати однакову довжину. 