diff '--exclude=.git' -ura --new-file edor/configure.ac edornew/configure.ac
--- edor/configure.ac	2025-04-10 08:27:16.942034345 +0000
+++ edornew/configure.ac	2025-04-10 08:27:34.112036996 +0000
@@ -13,6 +13,7 @@
   AS_HELP_STRING([--enable-cpp],[enable cpp, default: yes]),
   [case "${enableval}" in yes) cpp=true ;; no) cpp=false ;; *) AC_MSG_ERROR([bad value ${enableval} for --enable-cpp]) ;; esac],
   [cpp=true])
+
 AM_CONDITIONAL(CPP, test x"${cpp}" = x"true")
 
 # Check for CFLAGS
@@ -43,8 +44,8 @@
   AC_MSG_RESULT([yes])
   AC_DEFINE(ARM7L, 1, [armv7l])
   AC_CHECK_HEADERS(dlfcn.h signal.h)
-  AC_CHECK_HEADERS(libunwind.h, [], [AC_SUBST(UNW, "-Wno-c++98-compat-pedantic")])
-#not all platforms need these
+  AC_CHECK_HEADERS(libunwind.h) #  AC_CHECK_HEADERS(libunwind.h, [], [AC_SUBST(UNW, "-Wno-c++98-compat-pedantic")]) #this was at "long long", more in inc/main/armv7l
+  #not all platforms need these
   AC_SEARCH_LIBS([dladdr],[dl])
   AC_SEARCH_LIBS([_Uarm_init_local],[unwind-arm])
   ],
@@ -105,12 +106,39 @@
 #                                                  -O1
 #O3 is not removing symbols
 
-# Checks for library functions.
-
 AM_INIT_AUTOMAKE
 
 AC_CONFIG_FILES([Makefile s/Makefile])
 
+AC_MSG_CHECKING([shell])
+AS_IF([ [[ -n "$(test x"${SHELL}" != x"/bin/bash" && echo x)" ]] && [[ -n "$(test x"${SHELL}" != x"/bin/sh" && echo x)" ]] ],
+	[
+		AS_IF([ $(test -x /bin/bash) ],
+			[
+				AC_SUBST([RUN__SHELL], "/bin/bash")
+				AC_MSG_RESULT([set /bin/bash])
+			],
+			[
+				AS_IF([ $(test -x /bin/sh) ],
+					[
+						AC_SUBST([RUN__SHELL], "/bin/sh")
+						AC_MSG_RESULT([set /bin/sh])
+					],
+					[
+						AC_SUBST([RUN__SHELL], "${SHELL}")
+						AC_MSG_RESULT([is ${SHELL}])
+					]
+				)
+			]
+		)
+	],
+	[
+		#RUN__SHELL = "${SHELL}" is not enough
+		AC_SUBST([RUN__SHELL], "${SHELL}")
+		AC_MSG_RESULT([ok ${SHELL}])
+	]
+)
+
 AC_OUTPUT
 
 #echo -n >"./.${PROJ}info"
diff '--exclude=.git' -ura --new-file edor/debian/changelog edornew/debian/changelog
--- edor/debian/changelog	2025-04-10 08:27:16.982034349 +0000
+++ edornew/debian/changelog	2025-04-10 08:27:34.152037003 +0000
@@ -1,3 +1,27 @@
+edor (1-x68) focal; urgency=medium
+
+  * fix Error: PC not allowed in register list
+
+ -- bc <bc@bc-desktop>  Wed, 09 Apr 2025 19:33:43 +0300
+
+edor (1-x67) focal; urgency=medium
+
+  * fix armhf
+
+ -- bc <bc@bc-desktop>  Wed, 09 Apr 2025 14:22:35 +0300
+
+edor (1-x66) focal; urgency=medium
+
+  * switch fix
+
+ -- bc <bc@bc-desktop>  Wed, 09 Apr 2025 10:23:24 +0300
+
+edor (1-x65) focal; urgency=medium
+
+  * change keys
+
+ -- bc <bc@bc-desktop>  Wed, 09 Apr 2025 09:49:04 +0300
+
 edor (1-x64) focal; urgency=medium
 
   * fix ^P
diff '--exclude=.git' -ura --new-file edor/debian/control edornew/debian/control
--- edor/debian/control	2025-04-10 08:27:16.992034350 +0000
+++ edornew/debian/control	2025-04-10 08:27:34.162037005 +0000
@@ -2,7 +2,7 @@
 Section: utils
 Priority: optional
 Maintainer: Botescu Costin <costin.botescu@gmail.com>
-Build-Depends: libncurses-dev, libunwind-dev [armhf], debhelper-compat (= 11), dh-autoreconf
+Build-Depends: libncurses-dev, libunwind-dev [armhf], debhelper-compat (= 11), dh-autoreconf, bc
 Standards-Version: 4.5.0
 Homepage: https://github.com/colin-i/edor
 
diff '--exclude=.git' -ura --new-file edor/.github/workflows/appimage.yml edornew/.github/workflows/appimage.yml
--- edor/.github/workflows/appimage.yml	2025-04-10 08:27:16.632034309 +0000
+++ edornew/.github/workflows/appimage.yml	2025-04-10 08:27:33.792036935 +0000
@@ -7,7 +7,7 @@
 
 jobs:
  build:
-  runs-on: ubuntu-20.04
+  runs-on: ubuntu-22.04
   steps:
    - uses: actions/checkout@v3
    - name: Run a multi-line script
diff '--exclude=.git' -ura --new-file edor/.gitignore edornew/.gitignore
--- edor/.gitignore	2025-04-10 08:27:16.752034323 +0000
+++ edornew/.gitignore	2025-04-10 08:27:33.912036958 +0000
@@ -1,11 +1,8 @@
-aclocal.m4
-autom4te.cache/
-build-aux/
-configure
-Makefile.in
-.deps/
-config.log
-config.status
+/aclocal.m4
+/autom4te.cache
+/build-aux
+/configure
+/config.log
+/config.status
 Makefile
-.dirstamp
-edor*
+Makefile.in
diff '--exclude=.git' -ura --new-file edor/Makefile.am edornew/Makefile.am
--- edor/Makefile.am	2025-04-10 08:27:16.812034330 +0000
+++ edornew/Makefile.am	2025-04-10 08:27:33.982036971 +0000
@@ -1,14 +1,8 @@
 SUBDIRS = s
 
-#here will add
-.PHONY: test
 test:
-	cp -r s test
-	cd test && make clean && /bin/bash ./headless
-	rm -r test #it is a mirror, who can use it instead of ./s ?
-
-#install-exec-local:
-#	if [ ! -e "`cat ./bash_home`/.@PROJ@info" ]; then cp "./.@PROJ@info" "`cat ./bash_home`/" --preserve=ownership; fi
+	cd $(SUBDIRS) && $(MAKE) $@
+#	for var in $(SUBDIRS); do { cd $${var} && $(MAKE) $@; } || exit 1; cd ..; done
 
-#uninstall-local:
-#	if [ -e "`cat ./bash_home`/.@PROJ@info" ]; then rm "`cat ./bash_home`/.@PROJ@info"; fi
+#here will add
+.PHONY: test
diff '--exclude=.git' -ura --new-file edor/s/bar.c edornew/s/bar.c
--- edor/s/bar.c	2025-04-10 08:27:17.182034373 +0000
+++ edornew/s/bar.c	2025-04-10 08:27:34.362037044 +0000
@@ -51,13 +51,6 @@
 
 #include"base.h"
 
-#define protocol_simple "%u"
-#ifdef PLATFORM64
-#define protocol "%lu"
-#else
-#define protocol protocol_simple
-#endif
-
 #define err_len_min 2
 
 bool insensitive=false;
@@ -499,9 +492,9 @@
 	if(f/*true*/)return findingf(cursor,r,c);
 	return findingb(cursor,r,c);
 }
-void position_core(size_t y,size_t x){
+void position_core(size_t y,row_dword x){
 	char posbuf[10+1+10+1];
-	int n=sprintf(posbuf,protocol "," protocol,y+1,x+1);
+	int n=sprintf(posbuf,protocol "," protocol_simple,y+1,x+1); //x+1? last is null, so is still at the limit, and if not modified? /0 is ok, if not can add ==0xff..ff then =0xff..fe
 	int dif=getmaxx(poswn)-n;
 	if(dif!=0){
 		if(dif>0){
@@ -600,8 +593,9 @@
 		}
 	}
 }
+
 //0/1  not signed but will return at command
-static command_char go_to(bar_byte cursor){
+command_char go_to(bar_byte cursor){
 	int i=0;size_t y;size_t x;
 	for(;;){
 		if(input0[i]==','){
@@ -626,6 +620,33 @@
 	}
 	return command_false;
 }
+static void set_key(key_struct*from,char to){
+	memcpy(&keys[to],from,sizeof(key_struct));
+	if(keys[to].key_location!=nullptr){
+		char ix=keys[to].index;keys_row[ix]=to;
+		changekey(to);
+	}
+}
+#define is_a_z(p) input0[p]>='a'&&input0[p]<='z'
+//same as goto
+command_char change_key(bar_byte cursor){
+	if(is_a_z(0)){
+		if(is_a_z(1)){
+			if(input0[2]=='\0'){
+				char from=*input0-'a';
+				char to=input0[1]-'a';
+				key_struct aux;
+				memcpy(&aux,&keys[to],sizeof(key_struct));
+				set_key(&keys[from],to);
+				set_key(&aux,from);
+				rewriteprefs;
+				return command_ok;
+			}
+		}
+	}
+	return command_false;
+}
+
 command_char save(){
 	if(textfile!=nullptr){
 		return saving();
@@ -926,9 +947,14 @@
 void undo_loop(WINDOW*w){
 	for(;;){
 		int c=wgetch(w);
-		if(c==KEY_LEFT)undo(w);
-		else if(c==KEY_RIGHT)redo(w);
-		else break;
+		switch(c){//reread from mem or a special register? gcc same as if-else, from mem
+			case KEY_LEFT:
+				undo(w);break;
+			case KEY_RIGHT:
+				redo(w);break;
+			default:
+				return;
+		}
 	}
 }
 static bool replace(bar_byte cursor){
@@ -1002,6 +1028,7 @@
 }
 
 #define quick_get(z) ((WINDOW**)((void*)z))[1]
+#define quick_get3(z) ((WINDOW**)((void*)z))[2]
 #define find_returner return a==KEY_RESIZE?command_resize:command_ok;
 
 static void finds_total(int number,size_t y1,row_dword x1,size_t xr,row_dword xc,bool untouched,bar_byte cursor,WINDOW*w){
@@ -1245,7 +1272,7 @@
 	}else{
 		input=input0;
 		if(*comnrp==com_nr_goto_alt)cursor=sprintf(input,protocol ",",1+ytext
-			+(size_t)getcury(quick_get(comnrp)));
+			+(size_t)getcury(quick_get3(comnrp)));
 		else if(*comnrp==com_nr_ext){
 			extdata*d=((extdata**)comnrp)[1];
 			cursor=sprintf(input,"%s",(d->orig)[0]);//on prefs is len<=0xff and max_path_0 is 0x100
@@ -1278,9 +1305,9 @@
 					command_rewrite(y,ifback>right?right:ifback,pos,inputf,cursor,visib);
 					continue;
 				}
-			}else if(comnr<=com_nr_goto_numbers){
+			}else if(comnr<=com_nr_passcursor_numbers){
 				input[cursor]='\0';
-				r=go_to(cursor);
+				r=((command_char(*)(bar_byte))(((comnrp_define*)comnrp)[1]))(cursor);
 			}else if(comnr==com_nr_save){
 				input[cursor]='\0';
 				r=saves();
@@ -1371,7 +1398,7 @@
 		else if(a==KEY_RESIZE){r=command_resize;break;}
 		else{
 			const char*s=keyname(a);
-			if(strcmp(s,"^Q")==0){r=command_no;break;}
+			if(*s==Char_Ctrl&&s[1]==key_quit){r=command_no;break;}
 			if(cursor!=max_path){
 				char ch=(char)a;
 				if(no_char(ch)==false){
diff '--exclude=.git' -ura --new-file edor/s/base.h edornew/s/base.h
--- edor/s/base.h	2025-04-10 08:27:17.202034376 +0000
+++ edornew/s/base.h	2025-04-10 08:27:34.382037048 +0000
@@ -2,6 +2,7 @@
 //main
 //bar
 int c_to_xc(int,int);
+void changekey(char);
 void cpymembuf(size_t,row_dword,size_t,row_dword,char*);
 void deleting(size_t,size_t,size_t,size_t);
 bool deleting_init(size_t,row_dword,size_t,row_dword);
@@ -16,8 +17,12 @@
 void refreshrowsbot(WINDOW*,int,int);
 #define refreshrows(w,i) refreshrowsbot(w,i,getmaxy(w))
 void restore_rebase();
+#define mask_nomask 0
+#define ignored 0
+#define rewriteprefs setprefs(mask_nomask,ignored)
 bool row_alloc(row*,row_dword,size_t,row_dword);
 void row_set(row*,row_dword,row_dword,row_dword,const char*);
+void setprefs(int,bool);
 size_t sizemembuf(size_t,row_dword,size_t,row_dword);
 void vis(char,WINDOW*);
 //tw
@@ -38,10 +43,12 @@
 command_char save(void);
 command_char saving_base(char*);
 command_char question(const char*);
+command_char change_key(bar_byte);
 command_char command(char*);
 #define centering2(w,prw,pxc,right) position(0,0);centering3(w,prw,pxc,right);
 #define centering(w,prw,pxc) centering2(w,prw,pxc,false)
 #define centering_simple(w) centering(w,nullptr,nullptr)
+command_char go_to(bar_byte);
 WINDOW*position_init(void);
 void position(int,int);
 void position_reset(void);
@@ -66,7 +73,6 @@
 void aftercall_draw(WINDOW*);
 size_t init_aftercall();
 //tw
-void position_core(size_t,size_t);
 void centering3(WINDOW*,size_t*,row_dword*,bool);
 //tit
 bool bar_char(char,WINDOW*,bool);
@@ -74,6 +80,7 @@
 bool bar_clear(void);
 //tw,tit
 int centeringy(WINDOW*);
+void position_core(size_t,row_dword);
 
 //tw
 //main
@@ -89,8 +96,8 @@
 //main
 char split_conditions(char*,bool);
 bool split_grab(char**,size_t*,char*);
-void split_writeprefs(int);
-void split_readprefs(int);
+bool split_writeprefs(int);
+bool split_readprefs(int);
 void split_freeprefs();
 bool split_write_init(char*);
 char* split_write(size_t*,int,unsigned int*,bool*);
@@ -104,6 +111,10 @@
 extern bool mod_flag;
 extern bool insensitive;
 extern char*ocode_extension;
+extern key_struct*keys;
+extern char*keys_row;
+//bar,tit
+extern char key_quit;
 //bar,tw,tit
 extern size_t ytext;
 extern row_dword xtext;
diff '--exclude=.git' -ura --new-file edor/s/.gitignore edornew/s/.gitignore
--- edor/s/.gitignore	1970-01-01 00:00:00.000000000 +0000
+++ edornew/s/.gitignore	2025-04-10 08:27:34.332037038 +0000
@@ -0,0 +1,3 @@
+/.deps
+/edor*
+/main.h
diff '--exclude=.git' -ura --new-file edor/s/headless edornew/s/headless
--- edor/s/headless	2025-04-10 08:27:17.232034379 +0000
+++ edornew/s/headless	2025-04-10 08:27:34.412037053 +0000
@@ -3,47 +3,36 @@
 
 cp Makefile mk
 
-#replace common headers that are coming from a script
-a="\-DHAVE_STDIO_H=1 \-DHAVE_STDLIB_H=1 \-DHAVE_STRING_H=1 \-DHAVE_INTTYPES_H=1 \-DHAVE_STDINT_H=1 \-DHAVE_STRINGS_H=1 \-DHAVE_SYS_STAT_H=1 \-DHAVE_SYS_TYPES_H=1 \-DHAVE_UNISTD_H=1 \-DSTDC_HEADERS=1"
-grep --color "${a}" mk
-sed -i "s/${a}//g" mk
-grep --color "${a}" mk
-
-#input headers
-a="\-DHAVE_STDDEF_H=1 \-DHAVE_DIRENT_H=1 \-DHAVE_ERRNO_H=1 \-DHAVE_FCNTL_H=1 \-DHAVE_POLL_H=1 \-DHAVE_STDIO_H=1 \-DHAVE_STDLIB_H=1 \-DHAVE_STRING_H=1 \-DHAVE_UNISTD_H=1 \-DHAVE_TIME_H=1 \-DHAVE_SYS_STAT_H=1 \-DHAVE_CURSES_H=1"
-grep --color "${a}" mk
-sed -i "s/${a}//g" mk
-grep --color "${a}" mk
-
-if [ "${1}" = "1" ]; then
-	a="\-DPLATFORM64=1"
-	grep --color "${a}" mk
-	sed -i "s/${a}//g" mk
-	grep --color "${a}" mk
-	#and  if wanting 32
-fi
-
-a="edor_CPPFLAGS ="
-n=`grep "^${a}" -n Makefile | grep -o "^[^:]*"`
-if [ -n "${n}" ]; then
+#headers, first are default, second are our input
+#\-DHAVE_STDIO_H=1 \-DHAVE_STDLIB_H=1 \-DHAVE_STRING_H=1 \-DHAVE_INTTYPES_H=1 \-DHAVE_STDINT_H=1 \-DHAVE_STRINGS_H=1 \-DHAVE_SYS_STAT_H=1 \-DHAVE_SYS_TYPES_H=1 \-DHAVE_UNISTD_H=1
+#without \-DSTDC_HEADERS=1
+#\-DHAVE_STDDEF_H=1 \-DHAVE_DIRENT_H=1 \-DHAVE_ERRNO_H=1 \-DHAVE_FCNTL_H=1 \-DHAVE_POLL_H=1 \-DHAVE_STDIO_H=1 \-DHAVE_STDLIB_H=1 \-DHAVE_STRING_H=1 \-DHAVE_UNISTD_H=1 \-DHAVE_TIME_H=1 \-DHAVE_SYS_STAT_H=1 \-DHAVE_CURSES_H=1
+#c only headers \-DHAVE_STDBOOL_H=1
+#
+a=`grep "^DEFS =" mk`
+echo ${a} | grep --color "HAVE"
+b=`echo ${a} | sed "s/-DHAVE_[^_]*_H=1//g; s/-DHAVE_[^_]*_[^_]*_H=1//g;"`
+#
+c="edor_CPPFLAGS ="
+n=`grep "^${c}" -n Makefile | grep -o "^[^:]*"`
+if [ -n "${n}" ]; then #on c flags will be commented
 	#here when cpp flags
+	grep --color "${c}" mk
+	sed -i "${n}s/.*/${c}/" mk
+	grep --color "${c}" mk
 
-	grep --color "${a}" mk
-	sed -i "${n}s/.*/${a}/" mk
-	grep --color "${a}" mk
-
-	a="\-DUSE_FS=1"
-	grep --color "${a}" mk
-	sed -i "s/${a}//g" mk
-	grep --color "${a}" mk
-else
-	#c only headers
-	a="\-DHAVE_STDBOOL_H=1"
-	grep --color "${a}" mk
-	sed -i "s/${a}//g" mk
-	grep --color "${a}" mk
+	echo ${b} | grep --color "USE_FS"
+	b=`echo ${b} | sed "s/-DUSE_FS=1//g"`
+fi
+if [ "${1}" = "1" ]; then #rare test, if wanting 32
+	echo ${b} | grep --color "\-DPLATFORM64=1"
+	b=`echo ${b} | sed "s/\-DPLATFORM64=1//g"`
 fi
+a=$(echo ${a} | sed 's/\\/\\\\/g')
+b=$(echo ${b} | sed 's/\\/\\\\/g')
+#
+sed -i "0,/^${a}/s/^${a}/${b}/" mk #is only one
 
-./mh
+cat mk | grep "^DEFS"
 
-if [ -n "${2}" ]; then rm mk; fi
+/bin/bash ./mh && if [ -n "${2}" ]; then rm mk; fi
diff '--exclude=.git' -ura --new-file edor/s/inc/main/armv7/libunwind.h edornew/s/inc/main/armv7/libunwind.h
--- edor/s/inc/main/armv7/libunwind.h	2025-04-10 08:27:17.422034402 +0000
+++ edornew/s/inc/main/armv7/libunwind.h	2025-04-10 08:27:34.602037090 +0000
@@ -22,28 +22,55 @@
  UNW_REG_IP = -1,// instruction pointer
  UNW_REG_SP = -2 // stack pointer
 };
-# define LIBUNWIND_CONTEXT_SIZE 167
-# define LIBUNWIND_CURSOR_SIZE 179
-//'long long' is incompatible with C++98
-typedef unsigned long long uint64_t;
-struct unw_context_t {
- uint64_t data[LIBUNWIND_CONTEXT_SIZE];
-};
-typedef struct unw_context_t unw_context_t;
-struct unw_cursor_t {
- uint64_t data[LIBUNWIND_CURSOR_SIZE];
-};
-typedef struct unw_cursor_t unw_cursor_t;
-typedef unsigned int unw_word_t;
+
+//don't know on termux nowadays but on raspberry os is not unw_set_reg anymore, and unw_getcontext, ...
+
+//# define LIBUNWIND_CONTEXT_SIZE 167
+//# define LIBUNWIND_CURSOR_SIZE 179
+////'long long' is incompatible with C++98
+//typedef unsigned long long uint64_t;
+//struct unw_context_t {
+// uint64_t data[LIBUNWIND_CONTEXT_SIZE];
+//};
+//typedef struct unw_context_t unw_context_t;
+//struct unw_cursor_t {
+// uint64_t data[LIBUNWIND_CURSOR_SIZE];
+//};
+//typedef struct unw_cursor_t unw_cursor_t;
+//typedef unsigned int unw_word_t;
+typedef struct unw_tdep_context
+  {
+    unsigned long regs[16];
+  }
+unw_tdep_context_t;
+#define unw_context_t unw_tdep_context_t
+typedef unsigned int __uint32_t;
+typedef __uint32_t uint32_t;
+typedef uint32_t unw_word_t;
+typedef struct unw_cursor
+  {
+    unw_word_t opaque[4096];
+  }
+unw_cursor_t;
+
 typedef int unw_regnum_t;
+
 #ifdef __cplusplus
 extern "C" {
 #endif
-int unw_getcontext(unw_context_t *);
-int unw_init_local(unw_cursor_t *, unw_context_t *);
-int unw_step(unw_cursor_t *);
-int unw_get_reg(unw_cursor_t *, unw_regnum_t, unw_word_t *);
-int unw_set_reg(unw_cursor_t *, unw_regnum_t, unw_word_t);
+
+//int unw_getcontext(unw_context_t *);
+#define unw_tdep_getcontext(uc) ({ unw_tdep_context_t *unw_ctx = (uc); register unsigned long *r0 __asm__ ("r0"); unsigned long *unw_base = unw_ctx->regs; __asm__ __volatile__ ( ".align 2\n" "bx pc\n" "nop\n" ".code 32\n" "mov r0, #0\n" "stmia %[base], {r0-r14}\n" "adr r0, ret%=+1\n" "str r0, [%[base], #60]\n" "orr r0, pc, #1\n" "bx r0\n" ".code 16\n" "mov r0, #0\n" "ret%=:\n" : [r0] "=r" (r0) : [base] "r" (unw_base) : "memory", "cc"); (int)r0; })
+#define unw_getcontext unw_tdep_getcontext
+
+int _Uarm_init_local(unw_cursor_t *, unw_context_t *);
+#define unw_init_local _Uarm_init_local
+int _Uarm_step(unw_cursor_t *);
+#define unw_step _Uarm_step
+int _Uarm_get_reg(unw_cursor_t *, unw_regnum_t, unw_word_t *);
+#define unw_get_reg _Uarm_get_reg
+int _Uarm_set_reg(unw_cursor_t *, unw_regnum_t, unw_word_t);
+#define unw_set_reg _Uarm_set_reg
 #ifdef __cplusplus
 }
 #endif
diff '--exclude=.git' -ura --new-file edor/s/inc/stddef.h edornew/s/inc/stddef.h
--- edor/s/inc/stddef.h	2025-04-10 08:27:17.702034436 +0000
+++ edornew/s/inc/stddef.h	2025-04-10 08:27:34.872037142 +0000
@@ -1,2 +1,6 @@
 
-typedef long unsigned int size_t;
+#ifdef PLATFORM64
+	typedef long unsigned int size_t;
+#else
+	typedef unsigned int size_t;
+#endif
diff '--exclude=.git' -ura --new-file edor/s/inc/string.h edornew/s/inc/string.h
--- edor/s/inc/string.h	2025-04-10 08:27:17.752034441 +0000
+++ edornew/s/inc/string.h	2025-04-10 08:27:34.922037152 +0000
@@ -30,21 +30,21 @@
 #endif
 #endif
 
-#if defined(is_bar_c)||defined(is_sep_c)
+#if defined(is_main_c)||defined(is_tit_c)||defined(is_split_c)
 #ifdef __cplusplus
 extern "C" {
 #endif
-char*strrchr(const char*,int);
+int memcmp(void*,void*,size_t);
 #ifdef __cplusplus
 }
 #endif
 #endif
 
-#if defined(is_tit_c)||defined(is_split_c)
+#if defined(is_bar_c)||defined(is_sep_c)
 #ifdef __cplusplus
 extern "C" {
 #endif
-int memcmp(void*,void*,size_t);
+char*strrchr(const char*,int);
 #ifdef __cplusplus
 }
 #endif
diff '--exclude=.git' -ura --new-file edor/s/inc/unistd.h edornew/s/inc/unistd.h
--- edor/s/inc/unistd.h	2025-04-10 08:27:17.762034443 +0000
+++ edornew/s/inc/unistd.h	2025-04-10 08:27:34.932037154 +0000
@@ -1,7 +1,12 @@
 
 //#if defined(is_main_c)||defined(is_bar_c)||defined(is_split_c)
-typedef long int ssize_t;
+#ifdef PLATFORM64
+	typedef long int ssize_t;
+#else
+	typedef int ssize_t;
+#endif
 //#include "inc/stddef.h"
+
 #ifdef __cplusplus
 extern "C" {
 #endif
diff '--exclude=.git' -ura --new-file edor/s/main.c edornew/s/main.c
--- edor/s/main.c	2025-04-10 08:27:17.792034446 +0000
+++ edornew/s/main.c	2025-04-10 08:27:34.962037159 +0000
@@ -1,43 +1,3 @@
-#define hel1 "USAGE\n"
-#define hel2 " [filepath [line_termination: rn/r/n]]\
-\n      --remove-config      Remove configuration files.\
-\nINPUT\
-\nthis help: q(uit),up/down,mouse/touch V.scroll\
-\nMovement:\
-\n    [Ctrl/Alt/Shift +]arrows/home/end/del,page up,page down,backspace,enter\
-\n    p.s.: Ctrl+ left/right/del breaks at white-spaces and (),[]{}\
-\n    mouse/touch Click and V.scroll\
-\nCtrl+v = visual mode; Alt+v = visual line mode\
-\n    c = copy\
-\n    d = delete\
-\n    x = cut\
-\n    i = indent (I = flow indent)\
-\n    u = unindent (U = flow unindent)\
-\nCtrl+o = paste; Alt+O = paste at the beginning of the row\
-\ncommand mode: left,right,home,end,ctrl+q\
-\nCtrl+s = save file; Alt+s = save file as...\
-\nCtrl+g = go to row[,column]; Alt+g = \"current_row,\" is entered\
-\nCtrl+f = find text; Alt+f = refind text; Ctrl+c = word at cursor (alphanumerics and _); Alt+c = word from cursor\
-\n    if found\
-\n      Enter       = next\
-\n      Space       = previous\
-\n      Left Arrow  = [(next/prev)&] replace\
-\n      Right Arrow = total\
-\n      r           = reset replace text\
-\n      R           = modify replace text\
-\n    c = cancel\
-\n    other key to return\
-\nCtrl+u = undo; Alt+u = undo mode: left=undo,right=redo,other key to return\
-\nCtrl+r = redo\
-\nCtrl+h = titles (movement, Enter at done, ctrl+q, other keys to search)\
-\nCtrl+w = text wrapping (movement. another key to return)\
-\nCtrl+e = enable/disable internal mouse/touch\
-\nCtrl+n = disable/enable indentation\
-\nCtrl+t = enable/disable insensitive search\
-\nCtrl+a = enable/disable O language syntax; Alt+a = syntax rescan; Alt+A = change extension name (blank is all)\
-\nCtrl+j = enable/disable OA split syntax; Alt+j = change delimiter; Alt+J = change view delimiter\
-\n    Alt+p = change splits folder; Alt+P = change extension name for splits (blank is all)\
-\nCtrl+q = quit"
 
 #define is_main_c
 #ifdef HAVE_STDDEF_H
@@ -47,6 +7,7 @@
 #endif
 
 #include "top.h"
+#include "main.h"
 
 #ifdef HAVE_CURSES_H
 #include<curses.h>
@@ -180,7 +141,6 @@
 
 #include"base.h"
 
-#define ignored 0
 #define no_clue (size_t)-1
 
 #define normalize_yes -1
@@ -200,7 +160,6 @@
 size_t aftercall;
 size_t clue=no_clue;
 
-#define Char_Escape 27
 static char*mapsel=nullptr;
 //static char*text_file=nullptr;
 static size_t rows_spc=1;//at rows_expand
@@ -223,7 +182,7 @@
 #define stored_mouse_mask_q stored_mouse_mask!=0
 static bool indent_flag=true;
 #define mask_size 1
-#define mask_nomask 0
+//#define mask_nomask 0
 #define mask_mouse 1
 #define mask_indent 2
 #define mask_insensitive 4
@@ -562,7 +521,7 @@
 	do{
 		c=getch();
 		if(c==KEY_MOUSE){
-			MEVENT e;
+			MEVENT e;//switch case? a label can only be part of a statement and a declaration is not a statement
 			getmouse(&e);
 			if((e.bstate&BUTTON4_PRESSED)!=0)hmove(-1);
 			else
@@ -572,9 +531,9 @@
 			if(e.bstate==0)     // at wheel down (libncurses5 at bionic)
 		#endif
 			hmove(1);
-		}else if(c==KEY_DOWN)hmove(1);
-		else if(c==KEY_UP)hmove(-1);
-		else if(c==KEY_RESIZE)return true;
+		}else if(c==KEY_DOWN){hmove(1);}
+		else if(c==KEY_UP){hmove(-1);}
+		else if(c==KEY_RESIZE){return true;}
 	}while(c!='q');
 	//helpclear();wnoutrefresh(stdscr);
 
@@ -2031,6 +1990,7 @@
 	return false;
 }
 #define quick_pack(nr,w) comnrp_define args[2];((comnrp_define)args)[0]=nr;args[1]=(comnrp_define)w;
+#define quick_pack3(nr,fn,w) comnrp_define args[3];((comnrp_define)args)[0]=nr;args[1]=(comnrp_define)fn;args[2]=(comnrp_define)w;
 static bool find_mode(int nr,WINDOW*w){
 	quick_pack((long)nr,w)
 	command_char r=command((comnrp_define)args);
@@ -2089,15 +2049,24 @@
 		unsigned char sz=strlen(ocode_extension);//at prefs one byte is taken, and also input has 255 max
 		if(write(f,&sz,extlen_size)==extlen_size){
 			if(write(f,ocode_extension,sz)==sz){
-				split_writeprefs(f);
+				if(split_writeprefs(f)/*true*/){
+					char k=0;
+					if(memcmp(keys_row,keys_row_orig,number_of_keys)!=0)k=number_of_keys;
+					if(write(f,&k,sizeof(char))==sizeof(char)){
+						#pragma GCC diagnostic push
+						#pragma GCC diagnostic ignored "-Wunused-result"
+						write(f,keys_row,k);
+						#pragma GCC diagnostic pop
+					}
+				}
 			}
 		}
 	}
 	close(f);
 }
-static void setprefs(int flag,bool set){
+void setprefs(int flag,bool set){
 	if(prefs_file[0]!='\0'){
-		//can use O_RDWR and lseek SEEK_SET
+		//can use O_RDWR and lseek SEEK_SET and ftruncate(newsize)
 		int f=open(prefs_file,O_RDONLY);
 		if(f!=-1){
 			char mask;
@@ -2131,7 +2100,7 @@
 	memcpy(*pref_buf,newinput,cursor);
 	(*pref_buf)[cursor]='\0';
 	*pref_orig=*pref_buf;//at start extension_new is not 100%
-	setprefs(mask_nomask,ignored);
+	rewriteprefs;
 }
 static bool pref_change(WINDOW*w,char**pref_orig,char**pref_buf,bool sizedonly){
 	extdata d={pref_orig,pref_buf,sizedonly};
@@ -2144,6 +2113,23 @@
 	return true;
 }
 
+void changekey(char i){
+	key_struct*k=&keys[i];
+	char newkey=i+_0_to_A;
+	*(k->key_location)=newkey;
+	char pos_total=k->pos_total;
+	if(pos_total!=0){
+		unsigned short* pos=k->pos;
+		for(int j=0;j<pos_total;j++){
+			keys_helptext[pos[j]]=newkey+A_to_a;
+		}
+	}
+	unsigned short upos=k->upos;
+	if(upos!=0){
+		keys_helptext[upos]=newkey;
+	}
+}
+
 static time_t guardian=0;
 static bool loopin(WINDOW*w){
 	int c;
@@ -2185,121 +2171,119 @@
 			int z=wgetch(w);
 			nodelay(w,false);
 			int y;bool b;
-			switch(z){ //reread from mem or a special register? gcc same as if-else, from mem
-				case 'v': if(visual_mode(w,true)/*true*/)return true;break;
-				case 'o':
-					y=getcury(w);
-					if(xtext!=0){xtext=0;refreshpage(w);}
-					wmove(w,y,0);past(w);
-					break;
-				case 'g':
-					quick_pack(com_nr_goto_alt,w)
-					if(goto_mode((char*)args,w)/*true*/)return true;
-					break;
-				case 'f':
-					if(find_mode(com_nr_findagain,w)/*true*/)return true;break;
-				case 'c': if(find_mode(com_nr_findwordfrom,w)/*true*/)return true;break;
-				case 'u': vis('U',w);undo_loop(w);vis(' ',w);break;
-				case 's': b=savetofile(w,false);if(b/*true*/)return true;break;
-				case 'a': aftercall=aftercall_find();aftercall_draw(w);break;
-				case 'j': if(pref_change(w,&sdelimiter,&sdelimiter_new,true)/*true*/)return true;break;           //don't allow no size delimiters
-				case 'p': if(pref_change(w,&split_out,&split_out_new,false)/*true*/)return true;break;
-				case 'A': if(pref_change(w,&ocode_extension,&ocode_extension_new,false)/*true*/)return true;break;
-				case 'J': if(pref_change(w,&esdelimiter,&esdelimiter_new,true)/*true*/)return true;break;         //don't allow no size delimiters
-				case 'P': if(pref_change(w,&split_extension,&split_extension_new,false)/*true*/)return true;//break;
-			}
+			if(z==(key_visual+A_to_a)){if(visual_mode(w,true)/*true*/)return true;}
+			else if(z==(key_paste+A_to_a)){
+				y=getcury(w);
+				if(xtext!=0){xtext=0;refreshpage(w);}
+				wmove(w,y,0);past(w);
+			}else if(z==(key_goto+A_to_a)){
+				quick_pack3(com_nr_goto_alt,go_to,w)
+				if(goto_mode((char*)args,w)/*true*/)return true;
+			}else if(z==(key_find+A_to_a)){if(find_mode(com_nr_findagain,w)/*true*/)return true;}
+			else if(z==(key_findword+A_to_a)){if(find_mode(com_nr_findwordfrom,w)/*true*/)return true;}
+			else if(z==(key_undo+A_to_a)){vis('U',w);undo_loop(w);vis(' ',w);}
+			else if(z==(key_save+A_to_a)){b=savetofile(w,false);if(b/*true*/)return true;}
+			else if(z==(key_ocomp+A_to_a)){aftercall=aftercall_find();aftercall_draw(w);}
+			else if(z==(key_actswf+A_to_a)){if(pref_change(w,&sdelimiter,&sdelimiter_new,true)/*true*/)return true;}           //don't allow no size delimiters
+			else if(z==(key_actswf2+A_to_a)){if(pref_change(w,&split_out,&split_out_new,false)/*true*/)return true;}
+			else if(z==key_ocomp){if(pref_change(w,&ocode_extension,&ocode_extension_new,false)/*true*/)return true;}
+			else if(z==key_actswf){if(pref_change(w,&esdelimiter,&esdelimiter_new,true)/*true*/)return true;}         //don't allow no size delimiters
+			else if(z==key_actswf2){if(pref_change(w,&split_extension,&split_extension_new,false)/*true*/)return true;}
 		}else{
-			//QWERTyUiOp - p alts are taken
-			//ASdFGHJkl
-			// zxCVbNm
-			// ^M is 13 that comes also at Enter, ^I is 9 that comes also at Tab
-			// ^P at docker, something is not ok with the redraw
 			const char*s=keyname(c);
-			if(strcmp(s,"^V")==0){
-				if(visual_mode(w,false)/*true*/)return true;
-			}else if(strcmp(s,"^O")==0)past(w);
-			else if((strcmp(s,"^S")==0)){
-				bool b=savetofile(w,true);
-				if(b/*true*/)return true;
-			}else if(strcmp(s,"^G")==0){
-				char aa=com_nr_goto;
-				if(goto_mode(&aa,w)/*true*/)return true;
-			}else if(strcmp(s,"^F")==0){
-				if(find_mode(com_nr_find,w)/*true*/)return true;
-			}else if(strcmp(s,"^C")==0){
-				if(find_mode(com_nr_findword,w)/*true*/)return true;
-			}else if(strcmp(s,"^U")==0){
-				undo(w);
-			}else if(strcmp(s,"^R")==0){
-				redo(w);
-			}else if(strcmp(s,"^H")==0){
-				if(titles(w)/*true*/)return true;
-			}else if(strcmp(s,"^Q")==0){
-				if(mod_flag==false){
-					bar_clear();//errors
-					command_char q=question("And save");
-					if(q==command_ok){
-						q=save();
-						if(q==command_false)err_set(w);
+			if(*s==Char_Ctrl){//seems that all cases are ^ a letter \0
+				char chr=s[1];
+				if(chr==key_visual){
+					if(visual_mode(w,false)/*true*/)return true;
+				}else if(chr==key_paste)past(w);
+				else if(chr==key_save){
+					bool b=savetofile(w,true);
+					if(b/*true*/)return true;
+				}else if(chr==key_goto){
+					quick_pack(com_nr_goto,go_to)
+					if(goto_mode((char*)args,w)/*true*/)return true;
+				}else if(chr==key_find){
+					if(find_mode(com_nr_find,w)/*true*/)return true;
+				}else if(chr==key_findword){
+					if(find_mode(com_nr_findword,w)/*true*/)return true;
+				}else if(chr==key_undo){
+					undo(w);
+				}else if(chr==key_redo){
+					redo(w);
+				}else if(chr==key_titles){
+					if(titles(w)/*true*/)return true;
+				}else if(chr==key_quit){
+					if(mod_flag==false){
+						bar_clear();//errors
+						command_char q=question("And save");
+						if(q==command_ok){
+							q=save();
+							if(q==command_false)err_set(w);
+						}
+						if(q==command_resize)return true;
+						else if(q==command_false){
+							wnoutrefresh(stdscr);
+							wmove(w,getcury(w),getcurx(w));
+							continue;
+						}
 					}
-					if(q==command_resize)return true;
-					else if(q==command_false){
-						wnoutrefresh(stdscr);
-						wmove(w,getcury(w),getcurx(w));
-						continue;
+					if(restorefile!=nullptr)unlink(restorefile);//here restorefile is deleted
+					return false;
+				}else if(chr==key_insens){
+					bool b;char c;
+					if(insensitive/*true*/){insensitive=false;c=insensitive_disabled;}
+					else{insensitive=true;c=insensitive_enabled;}
+					setprefs(mask_insensitive,insensitive);//here the bit is set on full insensitive search
+					vis(c,w);//is not showing on stdscr without wnoutrefresh(thisWindow)
+				}else if(chr==key_mouse){
+					bool b;char c;
+					if(stored_mouse_mask_q){stored_mouse_mask=mousemask(0,nullptr);c=mouseevents_disabled;setprefs(mask_mouse,false);}
+					else{stored_mouse_mask=mousemask(ALL_MOUSE_EVENTS,nullptr);c=mouseevents_enabled;setprefs(mask_mouse,true);}
+					vis(c,w);
+				}else if(chr==key_indents){
+					char c;
+					if(indent_flag/*true*/){indent_flag=false;c=indent_disabled;}
+					else{indent_flag=true;c=indent_enabled;}
+					setprefs(mask_indent,indent_flag);
+					vis(c,w);//is not showing on stdscr without wnoutrefresh(thisWindow)
+				}else if(chr==key_ocomp){
+					if(ocompiler_flag/*true*/){ocompiler_flag=false;c=ocompiler_disabled;}
+					else{ocompiler_flag=true;c=ocompiler_enabled;
+						aftercall=aftercall_find();}
+					setprefs(mask_ocompiler,ocompiler_flag);
+					visual(c);//addch for more info, first to window, then wnoutrefresh to virtual, then doupdate to phisical
+					aftercall_draw(w);
+				}else if(chr==key_actswf){//joins //alt j is set delimiter,alt J escape delimiter
+					char c;
+					if(splits_flag/*true*/){splits_flag=false;c=splits_disabled;}
+					else{splits_flag=true;c=splits_enabled;}
+					setprefs(mask_splits,splits_flag);
+					vis(c,w);
+				}else if(chr==key_wrap){if(text_wrap(w)/*true*/)return true;}
+				else if(chr==key_swkey){
+					quick_pack(com_nr_swkey,change_key)
+					if(command((char*)args)==command_resize)return true;
+					wmove(w,getcury(w),getcurx(w));
+				}else type(c,w);//enter, tab, ^, unknown ctrls
+			}else{
+				if(strcmp(s,"KEY_F(1)")==0){
+					int cy=getcury(w);int cx=getcurx(w);
+					phelp=0;
+					int i=helpshow(0);
+					int mx=getmaxy(stdscr)-2;
+					for(;i<mx;i++){move(i,0);clrtoeol();}
+					helpshowlastrow(mx);
+					if(helpin(w)/*true*/){
+						ungetch(c);
+						return true;
 					}
+					wmove(w,cy,cx);
 				}
-				if(restorefile!=nullptr)unlink(restorefile);//here restorefile is deleted
-				return false;
-			}else if(strcmp(s,"^T")==0){
-				bool b;char c;
-				if(insensitive/*true*/){insensitive=false;c=insensitive_disabled;}
-				else{insensitive=true;c=insensitive_enabled;}
-				setprefs(mask_insensitive,insensitive);//here the bit is set on full insensitive search
-				vis(c,w);//is not showing on stdscr without wnoutrefresh(thisWindow)
-			}else if(strcmp(s,"^E")==0){
-				bool b;char c;
-				if(stored_mouse_mask_q){stored_mouse_mask=mousemask(0,nullptr);c=mouseevents_disabled;setprefs(mask_mouse,false);}
-				else{stored_mouse_mask=mousemask(ALL_MOUSE_EVENTS,nullptr);c=mouseevents_enabled;setprefs(mask_mouse,true);}
-				vis(c,w);
-			}else if(strcmp(s,"^N")==0){
-				char c;
-				if(indent_flag/*true*/){indent_flag=false;c=indent_disabled;}
-				else{indent_flag=true;c=indent_enabled;}
-				setprefs(mask_indent,indent_flag);
-				vis(c,w);//is not showing on stdscr without wnoutrefresh(thisWindow)
-			}else if(strcmp(s,"^A")==0){
-				if(ocompiler_flag/*true*/){ocompiler_flag=false;c=ocompiler_disabled;}
-				else{ocompiler_flag=true;c=ocompiler_enabled;
-					aftercall=aftercall_find();}
-				setprefs(mask_ocompiler,ocompiler_flag);
-				visual(c);//addch for more info, first to window, then wnoutrefresh to virtual, then doupdate to phisical
-				aftercall_draw(w);
-			}else if(strcmp(s,"^J")==0){//joins //alt j is set delimiter,alt J escape delimiter
-				char c;
-				if(splits_flag/*true*/){splits_flag=false;c=splits_disabled;}
-				else{splits_flag=true;c=splits_enabled;}
-				setprefs(mask_splits,splits_flag);
-				vis(c,w);
-			}else if(strcmp(s,"^W")==0){if(text_wrap(w)/*true*/)return true;}
-
-			//i saw these only when mousemask is ALL_MOUSE_EVENTS : focus in, focus out
-			else if(strcmp(s,"kxIN")==0||strcmp(s,"kxOUT")==0){}
-
-			else if(strcmp(s,"KEY_F(1)")==0){
-				int cy=getcury(w);int cx=getcurx(w);
-				phelp=0;
-				int i=helpshow(0);
-				int mx=getmaxy(stdscr)-2;
-				for(;i<mx;i++){move(i,0);clrtoeol();}
-				helpshowlastrow(mx);
-				if(helpin(w)/*true*/){
-					ungetch(c);
-					return true;
-				}
-				wmove(w,cy,cx);
-			}else type(c,w);
-			//continue;
+				//i saw these only when mousemask is ALL_MOUSE_EVENTS : focus in, focus out
+				else if(strcmp(s,"kxIN")==0||strcmp(s,"kxOUT")==0){}
+				else type(c,w);
+				//continue;
+			}
 		}
 	}
 }
@@ -2412,6 +2396,30 @@
 	return true;//it was a problem at input, not sure if was here, anyway here is easy to force with sudo chmod 600 /dev/tty
 }
 
+static void getkeys(char kp){
+	for(char i=0;i<number_of_keys;i++){
+		unsigned char ix;//this is unsigned because is unknown read
+		if(i<kp){
+			ix=keys_row_frompref[i];
+			if(ix>key_last_index)return;
+		}else{//this is very safe for when adding new keys and will write 0 at no changes that can be ok on many users pref files and one program
+			ix=keys_row_orig[i];
+			//keys_row_frompref[i]=ix; is already at define time
+		}
+		if(keys_frompref[ix].key_location!=nullptr)return;
+		char ix_orig=keys_row_orig[i];
+		memcpy(&keys_frompref[ix],&keys_orig[ix_orig],sizeof(key_struct));
+	}
+	keys=keys_frompref;
+	keys_row=keys_row_frompref;
+	for(char i=0;i<number_of_keys;i++){
+		char ix=keys_row[i];
+		if(keys_row_orig[i]!=ix){
+			changekey(ix);
+		}
+	}
+}
+
 static bool valid_ln_term(int argc,char**argv,bool*not_forced){
 	if(argc==3){
 		char*input_term=argv[2];
@@ -2469,7 +2477,8 @@
 		helptext=a;
 		memcpy(a,hel1,sz1);
 		a+=sz1;memcpy(a,f,szf);
-		memcpy(a+szf,hel2,sz2);
+		keys_helptext=a+szf;
+		memcpy(keys_helptext,hel2,sz2);
 		return true;
 	}
 	return false;
@@ -2515,7 +2524,16 @@
 					if(read(f,ocode_extension_new,len)==len){
 						ocode_extension=ocode_extension_new;
 						ocode_extension[len]='\0';
-						split_readprefs(f);
+						if(split_readprefs(f)/*true*/){
+							unsigned char k;
+							if(read(f,&k,sizeof(char))==sizeof(char)){
+								if(k<=number_of_keys){
+									if(read(f,keys_row_frompref,k)==k){
+										getkeys(k);
+									}
+								}
+							}
+						}
 					}
 				}
 			}
@@ -2845,7 +2863,7 @@
 			}
 			endwin();
 
-			if(clue!=no_clue)printf("last row where was an error at split write was: %lu\n",clue);
+			if(clue!=no_clue)printf("last row where was an error at split write was: " protocol "\n",clue);
 			if(ocode_extension_new!=nullptr){
 				free(ocode_extension_new);//also need it at change for view what is was
 				split_freeprefs();
diff '--exclude=.git' -ura --new-file edor/s/main.sh edornew/s/main.sh
--- edor/s/main.sh	1970-01-01 00:00:00.000000000 +0000
+++ edornew/s/main.sh	2025-04-10 08:27:34.982037163 +0000
@@ -0,0 +1,173 @@
+#!/bin/sh
+
+level_help=0
+level_names=1
+level_pref_wr=2
+level_pref_rd=3
+level_map=4
+if [ -z "${level}" ]; then level=${level_map}; fi
+
+f=main.h
+wr_n() { printf '%s' "$@" >> ${f}; echo >> ${f}; }
+wr () { printf '%s' "$@" >> ${f}; }
+wr2_n() { buf="${buf}$@
+"; }
+wr2 () { buf="${buf}$@"; }
+wr3_n() { buf2="${buf2}$@
+"; }
+wr3 () { buf2="${buf2}$@"; }
+wr4_n() { buf3="${buf3}$@
+"; }
+wr4 () { buf3="${buf3}$@"; }
+
+printf '%s\n' "#define hel1 \"USAGE\n\"" > ${f}
+wr "#define hel2 \""
+d2=" [filepath [line_termination: rn/r/n]]\
+\n      --remove-config      Remove configuration files.\
+\nINPUT\
+\nthis help: q(uit),up/down,mouse/touch V.scroll\
+\nMovement:\
+\n    [Ctrl/Alt/Shift +]arrows/home/end/del,page up,page down,backspace,enter\
+\n    p.s.: Ctrl+ left/right/del breaks at white-spaces and (),[]{}\
+\n    mouse/touch Click and V.scroll"
+wr "${d2}"
+d2s="$(echo -n "${d2}" | sed "s/\\\n/n/g" | wc -c)" #more at second sed of this kind, if here was \\\" was another command
+fix_s="$(echo ${d2s}+4 | bc)"
+fix_s2="$(echo ${fix_s}+1 | bc)"
+
+text="\ncommand mode: left,right,home,end,Ctrl+q\
+\nCtrl+v = visual mode; Alt+v = visual line mode\
+\n    c = copy\
+\n    d = delete\
+\n    x = cut\
+\n    i = indent (I = flow indent)\
+\n    u = unindent (U = flow unindent)\
+\nCtrl+o = paste; Alt+o = paste at the beginning of the row\
+\nCtrl+s = save file; Alt+s = save file as...\
+\nCtrl+g = go to row[,column]; Alt+g = \\\"current_row,\\\" is entered\
+\nCtrl+f = find text; Alt+f = refind text; Ctrl+c = word at cursor (alphanumerics and _); Alt+c = word from cursor\
+\n    if found\
+\n      Enter       = next\
+\n      Space       = previous\
+\n      Left Arrow  = [(next/prev)&] replace\
+\n      Right Arrow = total\
+\n      r           = reset replace text\
+\n      R           = modify replace text\
+\n    c = cancel\
+\n    other key to return\
+\nCtrl+u = undo; Alt+u = undo mode: left=undo,right=redo,other key to return\
+\nCtrl+r = redo\
+\nCtrl+h = titles (movement, Enter at done, Ctrl+q, other keys to search)\
+\nCtrl+w = text wrapping (movement. another key to return)\
+\nCtrl+e = enable/disable internal mouse/touch\
+\nCtrl+n = disable/enable indentation\
+\nCtrl+t = enable/disable insensitive search\
+\nCtrl+a = enable/disable O language syntax; Alt+a = syntax rescan; Alt+A = change extension name (blank is all)\
+\nCtrl+j = enable/disable OA split syntax; Alt+j = change delimiter; Alt+J = change view delimiter\
+\n    Alt+p = change splits folder; Alt+P = change extension name for splits (blank is all)\
+\nCtrl+z = switch keys, applies to Ctrl and lower/upper Alt (example: az , +a becomes +z and +z becomes +a)\
+\nCtrl+q = quit\""
+wr_n "${text}"
+
+if [ ${level} -eq ${level_help} ]; then
+	exit 0
+fi
+
+#QWERT U O y   ip
+#AS FGHJ   dkl
+# Z CV N   xb  m
+# ^M is 13 that comes also at Enter, ^I is 9 that comes also at Tab
+# ^P at docker, something is not ok with the redraw
+# ^A in termux is from Ctrl+Alt+a
+
+textsed="$(echo "${text}" | sed "s/\\\n/n/g; s/\\\\\"/\"/g")"  # replace \n to n and \\\" to \"(this will go " at grep). \ at endings are 0
+#sh will not see that \n but will cut ok
+search_pos () {
+	wr2 ${3}
+	txt=$(printf "$1+\\$(printf %o $2)")
+	p=$(echo "${textsed}" | grep -b -o ${txt} | cut -d':' -f1 )
+	a=
+	for nr in ${p}; do
+		nr=$(echo $(if [ -n "$4" ]; then echo -n ${fix_s2}; else echo -n ${fix_s}; fi)+${nr} | bc)
+		wr2 "${a}${nr}"
+		if [ -z "${a}" ]; then a=","; fi
+		z=$((z+1))
+	done
+}
+
+nothing="{nullptr,nullptr,0,0,0}"
+
+_find_pos () { #name=$1 letter=$2 ctrls=$3 alt=$4 bigalt=$5
+	if [ -z "${is_extern}" ]; then wr "static "; fi
+	wr "char key_${1}=$(echo ${2}-32 | bc);"
+	wr2 "{&key_${1},(unsigned short[]){"
+	e=
+	z=0
+	if [ ${3} -ne 0 ]; then
+		search_pos Ctrl ${2} "" 1
+		e=,
+	fi
+	if [ -n "${4}" ]; then
+		search_pos Alt ${2} ${e}
+	fi
+	wr2 "},$z,"
+	if [ -n "${5}" ]; then
+		nr=$(echo ${2}-32 | bc)
+		search_pos Alt ${nr}
+	else
+		wr2 "0"
+	fi
+	wr2 ",${number_of_keys}}"
+	wr3 $((${2}-97)); wr4 "${nothing}"
+	number_of_keys=$((number_of_keys+1))
+}
+find_pos () {
+	wr2 ","; wr3 ","; wr4 ","
+	_find_pos $1 $2 $3 $4 $5
+}
+
+number_of_keys=0
+_find_pos                 ocomp            97 1 1 1   #a
+i=98
+while [ $i -lt 123 ]; do
+	case $i in
+		99) find_pos findword          $i 1 1;;   #c
+		101) find_pos mouse            $i 1;;     #e
+		102) find_pos find             $i 1 1;;   #f
+		103) find_pos goto             $i 1 1;;   #g
+		104) find_pos titles           $i 1;;     #h
+		106) find_pos actswf           $i 1 1 1;; #j
+		110) find_pos indents          $i 1;;     #n
+		111) find_pos paste            $i 1 1;;   #o
+		112) find_pos actswf2          $i 0 1 1;; #p
+		113) is_extern=x find_pos quit $i 3;;     #q
+		114) find_pos redo             $i 1;;     #r
+		115) find_pos save             $i 1 1;;   #s
+		116) find_pos insens           $i 1;;     #t
+		117) find_pos undo             $i 1 1;;   #u
+		118) find_pos visual           $i 1 1;;   #v
+		119) find_pos wrap             $i 1;;     #w
+		122) find_pos swkey            $i 1;;     #z
+		*) wr2 ",${nothing}"; wr4 ",${nothing}";;
+	esac
+	i=$((i+1))
+done
+wr_n ""
+
+wr_n "#define A_to_a 0x20"
+if [ ${level} -ge ${level_pref_wr} ]; then
+	wr_n "static char keys_row_orig[]={${buf2}};"
+	wr_n "char* keys_row=keys_row_orig;"
+	if [ ${level} -ge ${level_pref_rd} ]; then
+		wr_n "static char keys_row_frompref[]={${buf2}};"
+		if [ ${level} -ge ${level_map} ]; then
+			wr_n "static key_struct keys_frompref[]={${buf3}};"  #important to define same here and not at runtime
+			wr_n "static key_struct keys_orig[]={${buf}};"
+			wr_n "key_struct*keys=keys_orig;"
+			wr_n "static char*keys_helptext;"
+			wr_n "#define key_last_index $((122-97))"
+			wr_n "#define _0_to_A 0x41"
+			wr_n "#define number_of_keys ${number_of_keys}"
+		fi
+	fi
+fi
diff '--exclude=.git' -ura --new-file edor/s/Makefile.am edornew/s/Makefile.am
--- edor/s/Makefile.am	2025-04-10 08:27:17.162034371 +0000
+++ edornew/s/Makefile.am	2025-04-10 08:27:34.342037040 +0000
@@ -6,5 +6,28 @@
 edor_LDADD = -lcurses
 edor_CFLAGS = @CSS@
 if CPP
-edor_CPPFLAGS = -x c++ -Wno-old-style-cast -Wno-c++98-compat @UNW@
+edor_CPPFLAGS = -x c++ -Wno-old-style-cast @UNW@
+# -Wno-c++98-compat
 endif
+
+CLEANFILES = ${bin_PROGRAMS}t
+BUILT_SOURCES = main.h
+CLEANFILES += main.h
+
+test: $(BUILT_SOURCES)
+	flag=`echo "${DEFS}" | grep -o "\-DARM7L=1"`; \
+	flag2=`echo "${DEFS}" | grep -o "\-DPLATFORM64=1"`; \
+	text="$(CC) $${flag} $${flag2} -I. ${edor_SOURCES} ${edor_LDADD} ${LIBS} -o ${bin_PROGRAMS}t"; \
+	echo $${text}; \
+	$${text}
+#clean: #here, unlike .PHONY, will overwrite the clean rule
+#	rm -f ${bin_PROGRAMS}t
+
+main.h: main.sh
+	if [ -n "${RUN__SHELL}" ]; then ${RUN__SHELL} ./main.sh; \
+	else $(SHELL) ./main.sh; fi
+#or @RUN__SHELL@ but is not rerunable
+#else in case ${SHELL} was "" and make is coming with a $(SHELL)
+
+#here will add
+.PHONY: test
diff '--exclude=.git' -ura --new-file edor/s/mdh edornew/s/mdh
--- edor/s/mdh	2025-04-10 08:27:17.832034451 +0000
+++ edornew/s/mdh	2025-04-10 08:27:35.012037169 +0000
@@ -1,2 +1,2 @@
 
-extraflags="CFLAGS=-g" ./mh
+extraflags="CFLAGS=-g" ./mh "$@"
diff '--exclude=.git' -ura --new-file edor/s/mh edornew/s/mh
--- edor/s/mh	2025-04-10 08:27:17.862034455 +0000
+++ edornew/s/mh	2025-04-10 08:27:35.042037175 +0000
@@ -1 +1 @@
-make -f mk ${extraflags}
+make -f mk AM_MAKEFLAGS="-f mk" ${extraflags} "$@"
diff '--exclude=.git' -ura --new-file edor/s/split.c edornew/s/split.c
--- edor/s/split.c	2025-04-10 08:27:17.922034462 +0000
+++ edornew/s/split.c	2025-04-10 08:27:35.112037189 +0000
@@ -326,7 +326,7 @@
 	return false;
 }
 
-void split_writeprefs(int f){
+bool split_writeprefs(int f){
 	unsigned char sz=strlen(sdelimiter);
 	if(write(f,&sz,extlen_size)==extlen_size){
 		if(write(f,sdelimiter,sz)==sz){
@@ -338,10 +338,9 @@
 						if(write(f,split_out,sz)==sz){
 							sz=strlen(split_extension);
 							if(write(f,&sz,extlen_size)==extlen_size){
-								#pragma GCC diagnostic push
-								#pragma GCC diagnostic ignored "-Wunused-result"
-								write(f,split_extension,sz);
-								#pragma GCC diagnostic pop
+								if(write(f,split_extension,sz)==sz){
+									return true;
+								}
 							}
 						}
 					}
@@ -349,8 +348,9 @@
 			}
 		}
 	}
+	return false;
 }
-void split_readprefs(int f){
+bool split_readprefs(int f){
 	unsigned char len;
 	if(read(f,&len,extlen_size)==extlen_size){
 		sdelimiter_new=(char*)malloc(len+1);
@@ -376,6 +376,7 @@
 												if(read(f,split_extension_new,len)==len){
 													split_extension_new[len]='\0';
 													split_extension=split_extension_new;
+													return true;
 												}
 											}
 										}
@@ -388,6 +389,7 @@
 			}
 		}
 	}
+	return false;
 }
 void split_freeprefs(){
 	if(sdelimiter_new!=nullptr){
diff '--exclude=.git' -ura --new-file edor/s/tit.c edornew/s/tit.c
--- edor/s/tit.c	2025-04-10 08:27:17.962034467 +0000
+++ edornew/s/tit.c	2025-04-10 08:27:35.142037195 +0000
@@ -33,6 +33,12 @@
 	attrset(COLOR_PAIR(*color));
 	return singlechar;
 }
+static size_t*yvals;
+static void position_translated(WINDOW*w){
+	size_t y;row_dword x;
+	fixed_yx(&y,&x,getcury(w),getcurx(w));
+	position_core(yvals[y],x);
+}
 
 bool titles(WINDOW*w){
 	//calculate rows required
@@ -50,7 +56,8 @@
 		}
 	}
 
-	rowswrap=(row*)malloc((n*sizeof(row))+(n*sizeof(size_t)));//same hack as tw.c, extra alloc to free once
+	size_t nn=n==0?1:n;//to fast position_core, and is good to not malloc(0)
+	rowswrap=(row*)malloc((nn*sizeof(row))+(nn*sizeof(size_t)));//same hack as tw.c, extra alloc to free once
 	if(rowswrap!=nullptr){
 		store_rows=rows;
 		store_rows_tot=rows_tot;
@@ -58,36 +65,52 @@
 			store_aftercall=aftercall;
 		}
 
-		size_t m=0;size_t*yvals=(size_t*)&rowswrap[n];
-		for(size_t i=0;m!=n;i++){
-			row*r=&rows[i];
-			if(r->sz>1){
-				char*s=r->data;
-				if(*s!='\t'&&*s!=' '){
-					s+=r->sz-1;
-					if(*s=='{'||*s==')'){
-						row*rw=&rowswrap[m];
-						rw->data=r->data;
-						rw->sz=r->sz;
-						if(i>=aftercall)aftercall=m;// else let to be old rows_tot value? it looks ok knowing is comparing with a bigger rows_tot
-						yvals[m]=i;
-						m++;
+		//only if wanting to stay where it is now, but we are not searching from start at the moment, so it is a 50/50 case
+		//size_t ytext_dif=~0;size_t near_ytext=0;size_t near_ytext_translated=0;
+		size_t m=0;yvals=(size_t*)&rowswrap[nn];
+		size_t orig_ytext;row_dword orig_xtext;
+		fixed_yx(&orig_ytext,&orig_xtext,getcury(w),getcurx(w));
+
+		if(n!=0){
+			for(size_t i=0;m!=n;i++){
+				row*r=&rows[i];
+				if(r->sz>1){
+					char*s=r->data;
+					if(*s!='\t'&&*s!=' '){
+						s+=r->sz-1;
+						if(*s=='{'||*s==')'){
+							row*rw=&rowswrap[m];
+							rw->data=r->data;
+							rw->sz=r->sz;
+							if(i>=aftercall)aftercall=m;// else let to be old rows_tot value? it looks ok knowing is comparing with a bigger rows_tot
+							yvals[m]=i;
+							//size_t dif=i>ytext?i-ytext:ytext-i;
+							//if(dif<ytext_dif){
+							//	dif=ytext_dif;near_ytext=i;near_ytext_translated=m;
+							//}
+							m++;
+						}
 					}
 				}
 			}
+			rows_tot=n;
+		}else{
+			row*rw=&rowswrap[0];
+			rw->sz=0;
+			*yvals=0;
+			rows_tot=1;
 		}
 
-		size_t orig_ytext;row_dword orig_xtext;
-		fixed_yx(&orig_ytext,&orig_xtext,getcury(w),getcurx(w));
-
-		rows=rowswrap;rows_tot=n;
-		ytext=0;xtext=0;
+		rows=rowswrap;
+		ytext=0;//ytext=near_ytext_translated;
+		xtext=0;
 
 		//visual
 		bar_clear();
 		visual('H');
 		refreshpage(w);//visual shows now only with this
 		wmove(w,0,0);  //                        or this
+		position_translated(w);//position_core(near_ytext,0);
 
 		//loop
 		char color=color_0;
@@ -96,16 +119,21 @@
 			int b=wgetch(w);
 			z=movment(b,w);
 			if(z==movement_resize){extra_unlock(orig_ytext,orig_xtext,w);return true;}
-			else if(z==movement_processed)continue;
+			else if(z==movement_processed){
+				position_translated(w);
+				continue;
+			}
 			int r=getcury(w);
 			size_t y=ytext+r;
 			if(b==Char_Return){
 				if(y<rows_tot){
 					orig_ytext=yvals[y];
+					orig_xtext=0;//or fixed_x(y,&orig_xtext,r,getcurx(w)) but is not important and is a 50/50 case
 				}
 				break;
 			}
-			if(strcmp(keyname(b),"^Q")==0)break;
+			const char*kname=keyname(b);
+			if(*kname==Char_Ctrl&&kname[1]==key_quit)break;
 
 			//find next row start same as [0,x)+b and wmove there
 			singlechar=titcolor(b,&color,w,singlechar);
@@ -123,6 +151,7 @@
 							if(rw2->data[sz]==b){
 								ytext=y;
 								wmove(w,centeringy(w),c);
+								position_core(yvals[y],sz);
 								break;
 							}
 						}
@@ -135,7 +164,8 @@
 		if(color!=color_0)attrset(color_0);//reset back
 		bar_char(' ',w,singlechar);//and clear, can set new_v or err for later clear but is extra
 		visual(' ');
-		extra_unlock(orig_ytext,orig_xtext,w);
+		extra_unlock(orig_ytext,orig_xtext,w);//here xtext to be what was Enter selected now
+		position_core(orig_ytext,orig_xtext);
 	}
 
 	return false;
diff '--exclude=.git' -ura --new-file edor/s/top.h edornew/s/top.h
--- edor/s/top.h	2025-04-10 08:27:17.972034468 +0000
+++ edornew/s/top.h	2025-04-10 08:27:35.162037199 +0000
@@ -34,7 +34,10 @@
 	bool sizedonly;
 }extdata;
 
-#define Char_Return 0xd
+#define Char_Return 0xd  //main bar tit
+#define Char_Escape 0x1b //main
+#define Char_Ctrl 0x5e   //main bar tit
+
 #define row_pad 0xF
 #define tab_sz 6
 //can be 127(ascii Delete) or 263, note: Ctrl+h generates 263
@@ -47,9 +50,10 @@
 	#define com_nr_find_numbers com_nr_findwordfrom
 #define com_nr_goto 4
 #define com_nr_goto_alt 5
-	#define com_nr_goto_numbers com_nr_goto_alt
-#define com_nr_save 6
-#define com_nr_ext 7
+#define com_nr_swkey 6
+	#define com_nr_passcursor_numbers com_nr_swkey
+#define com_nr_save 7
+#define com_nr_ext 8
 
 #define is_word_char(a) ('0'<=a&&(a<='9'||('A'<=a&&(a<='Z'||(a=='_'||('a'<=a&&a<='z'))))))
 
@@ -86,3 +90,19 @@
 #define swrite_bad true
 
 #define default_extension (char*)"oc"
+
+#define protocol_simple "%u"
+#ifdef PLATFORM64
+#define protocol "%lu"
+#else
+#define protocol protocol_simple
+#endif
+
+//main,bar
+typedef struct{
+	char* key_location;
+	unsigned short*pos;
+	char pos_total;
+	unsigned short upos;
+	char index;
+}key_struct;
