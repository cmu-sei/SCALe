/*
 *  Name: dos2unix
 *  Documentation:
 *    Remove cr ('\x0d') characters from a file.
 *
 *  The dos2unix package is distributed under FreeBSD style license.
 *  See also http://www.freebsd.org/copyright/freebsd-license.html
 *  --------
 *
 *  Copyright (C) 2009-2015 Erwin Waterlander
 *  Copyright (C) 1998 Christian Wurll
 *  Copyright (C) 1998 Bernd Johannes Wuebben
 *  Copyright (C) 1994-1995 Benjamin Lin.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice in the documentation and/or other materials provided with
 *     the distribution.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
 *  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE
 *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 *  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 *  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 *  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *  == 1.0 == 1989.10.04 == John Birchfield (jb@koko.csustan.edu)
 *  == 1.1 == 1994.12.20 == Benjamin Lin (blin@socs.uts.edu.au)
 *     Cleaned up for Borland C/C++ 4.02
 *  == 1.2 == 1995.03.16 == Benjamin Lin (blin@socs.uts.edu.au)
 *     Modified to more conform to UNIX style.
 *  == 2.0 == 1995.03.19 == Benjamin Lin (blin@socs.uts.edu.au)
 *     Rewritten from scratch.
 *  == 2.1 == 1995.03.29 == Benjamin Lin (blin@socs.uts.edu.au)
 *     Conversion to SunOS charset implemented.
 *  == 2.2 == 1995.03.30 == Benjamin Lin (blin@socs.uts.edu.au)
 *     Fixed a bug in 2.1 where in new-file mode, if outfile already exists
 *     conversion can not be completed properly.
 *
 * Added Mac text file translation, i.e. \r to \n conversion
 * Bernd Johannes Wuebben, wuebben@kde.org
 * Wed Feb  4 19:12:58 EST 1998
 *
 * Added extra newline if ^M occurs
 * Christian Wurll, wurll@ira.uka.de
 * Thu Nov 19 1998
 *
 *  See ChangeLog.txt for complete version history.
 *
 */


/* #define DEBUG 1 */
#define __DOS2UNIX_C

#include "common.h"
#include "dos2unix.h"
#ifdef D2U_UNICODE
#if !defined(__MSDOS__) && !defined(_WIN32) && !defined(__OS2__)  /* Unix, Cygwin */
# include <langinfo.h>
#endif
#endif

void PrintLicense(void)
{
  printf("%s", _("\
Copyright (C) 2009-2015 Erwin Waterlander\n\
Copyright (C) 1998      Christian Wurll (Version 3.1)\n\
Copyright (C) 1998      Bernd Johannes Wuebben (Version 3.0)\n\
Copyright (C) 1994-1995 Benjamin Lin\n\
All rights reserved.\n\n"));
  PrintBSDLicense();
}

#ifdef D2U_UNICODE
void StripDelimiterW(FILE* ipInF, FILE* ipOutF, CFlag *ipFlag, wint_t CurChar, unsigned int *converted, const char *progname)
{
  wint_t TempNextChar;
  /* CurChar is always CR (x0d) */
  /* In normal dos2unix mode put nothing (skip CR). */
  /* Don't modify Mac files when in dos2unix mode. */
  if ( (TempNextChar = d2u_getwc(ipInF, ipFlag->bomtype)) != WEOF) {
    d2u_ungetwc( TempNextChar, ipInF, ipFlag->bomtype);  /* put back peek char */
    if ( TempNextChar != 0x0a ) {
      d2u_putwc(CurChar, ipOutF, ipFlag, progname);  /* Mac line, put back CR */
    } else {
      (*converted)++;
      if (ipFlag->NewLine) {  /* add additional LF? */
        d2u_putwc(0x0a, ipOutF, ipFlag, progname);
      }
    }
  }
  else if ( CurChar == 0x0d ) {  /* EOF: last Mac line delimiter (CR)? */
    d2u_putwc(CurChar, ipOutF, ipFlag, progname);
  }
}
#endif

void StripDelimiter(FILE* ipInF, FILE* ipOutF, CFlag *ipFlag, int CurChar, unsigned int *converted)
{
  int TempNextChar;
  /* CurChar is always CR (x0d) */
  /* In normal dos2unix mode put nothing (skip CR). */
  /* Don't modify Mac files when in dos2unix mode. */
  if ( (TempNextChar = fgetc(ipInF)) != EOF) {
    ungetc( TempNextChar, ipInF );  /* put back peek char */
    if ( TempNextChar != '\x0a' ) {
      fputc( CurChar, ipOutF );  /* Mac line, put back CR */
    } else {
      (*converted)++;
      if (ipFlag->NewLine) {  /* add additional LF? */
        fputc('\x0a', ipOutF);
      }
    }
  }
  else if ( CurChar == '\x0d' ) {  /* EOF: last Mac line delimiter (CR)? */
    fputc( CurChar, ipOutF );
  }
}

/* converts stream ipInF to UNIX format text and write to stream ipOutF
 * RetVal: 0  if success
 *         -1  otherwise
 */
#ifdef D2U_UNICODE
int ConvertDosToUnixW(FILE* ipInF, FILE* ipOutF, CFlag *ipFlag, const char *progname)
{
    int RetVal = 0;
    wint_t TempChar;
    wint_t TempNextChar;
    unsigned int line_nr = 1;
    unsigned int converted = 0;
    char *errstr;

    ipFlag->status = 0;

    /* CR-LF -> LF */
    /* LF    -> LF, in case the input file is a Unix text file */
    /* CR    -> CR, in dos2unix mode (don't modify Mac file) */
    /* CR    -> LF, in Mac mode */
    /* \x0a = Newline/Line Feed (LF) */
    /* \x0d = Carriage Return (CR) */

    switch (ipFlag->FromToMode)
    {
      case FROMTO_DOS2UNIX: /* dos2unix */
        while ((TempChar = d2u_getwc(ipInF, ipFlag->bomtype)) != WEOF) {  /* get character */
          if ((ipFlag->Force == 0) &&
              (TempChar < 32) &&
              (TempChar != 0x0a) &&  /* Not an LF */
              (TempChar != 0x0d) &&  /* Not a CR */
              (TempChar != 0x09) &&  /* Not a TAB */
              (TempChar != 0x0c)) {  /* Not a form feed */
            RetVal = -1;
            ipFlag->status |= BINARY_FILE ;
            if (ipFlag->verbose) {
              if ((ipFlag->stdio_mode) && (!ipFlag->error)) ipFlag->error = 1;
              fprintf(stderr, "%s: ", progname);
              fprintf(stderr, _("Binary symbol 0x00%02X found at line %u\n"),TempChar, line_nr);
            }
            break;
          }
          if (TempChar != 0x0d) {
            if (TempChar == 0x0a) /* Count all DOS and Unix line breaks */
              ++line_nr;
            if (d2u_putwc(TempChar, ipOutF, ipFlag, progname) == WEOF) {
              RetVal = -1;
              if (ipFlag->verbose) {
                if (!(ipFlag->status & UNICODE_CONVERSION_ERROR)) {
                  ipFlag->error = errno;
                  errstr = strerror(errno);
                  fprintf(stderr, "%s: ", progname);
                  fprintf(stderr, _("can not write to output file: %s\n"), errstr);
                }
              }
              break;
            }
          } else {
            StripDelimiterW( ipInF, ipOutF, ipFlag, TempChar, &converted, progname);
          }
        }
        break;
      case FROMTO_MAC2UNIX: /* mac2unix */
        while ((TempChar = d2u_getwc(ipInF, ipFlag->bomtype)) != WEOF) {
          if ((ipFlag->Force == 0) &&
              (TempChar < 32) &&
              (TempChar != 0x0a) &&  /* Not an LF */
              (TempChar != 0x0d) &&  /* Not a CR */
              (TempChar != 0x09) &&  /* Not a TAB */
              (TempChar != 0x0c)) {  /* Not a form feed */
            RetVal = -1;
            ipFlag->status |= BINARY_FILE ;
            if (ipFlag->verbose) {
              if ((ipFlag->stdio_mode) && (!ipFlag->error)) ipFlag->error = 1;
              fprintf(stderr, "%s: ", progname);
              fprintf(stderr, _("Binary symbol 0x00%02X found at line %u\n"), TempChar, line_nr);
            }
            break;
          }
          if ((TempChar != 0x0d)) {
              if (TempChar == 0x0a) /* Count all DOS and Unix line breaks */
                ++line_nr;
              if(d2u_putwc(TempChar, ipOutF, ipFlag, progname) == WEOF) {
                RetVal = -1;
                if (ipFlag->verbose) {
                  if (!(ipFlag->status & UNICODE_CONVERSION_ERROR)) {
                    ipFlag->error = errno;
                    errstr = strerror(errno);
                    fprintf(stderr, "%s: ", progname);
                    fprintf(stderr, _("can not write to output file: %s\n"), errstr);
                  }
                }
                break;
              }
            }
          else{
            /* TempChar is a CR */
            if ( (TempNextChar = d2u_getwc(ipInF, ipFlag->bomtype)) != WEOF) {
              d2u_ungetwc( TempNextChar, ipInF, ipFlag->bomtype);  /* put back peek char */
              /* Don't touch this delimiter if it's a CR,LF pair. */
              if ( TempNextChar == 0x0a ) {
                d2u_putwc(0x0d, ipOutF, ipFlag, progname); /* put CR, part of DOS CR-LF */
                continue;
              }
            }
            if (d2u_putwc(0x0a, ipOutF, ipFlag, progname) == WEOF) { /* MAC line end (CR). Put LF */
                RetVal = -1;
                if (ipFlag->verbose) {
                  if (!(ipFlag->status & UNICODE_CONVERSION_ERROR)) {
                    ipFlag->error = errno;
                    errstr = strerror(errno);
                    fprintf(stderr, "%s: ", progname);
                    fprintf(stderr, _("can not write to output file: %s\n"), errstr);
                  }
                }
                break;
              }
            converted++;
            line_nr++; /* Count all Mac line breaks */
            if (ipFlag->NewLine) {  /* add additional LF? */
              d2u_putwc(0x0a, ipOutF, ipFlag, progname);
            }
          }
        }
        break;
      default: /* unknown FromToMode */
      ;
#if DEBUG
      fprintf(stderr, "%s: ", progname);
      fprintf(stderr, _("program error, invalid conversion mode %d\n"),ipFlag->FromToMode);
      exit(1);
#endif
    }
    if (ipFlag->status & UNICODE_CONVERSION_ERROR)
        ipFlag->line_nr = line_nr;
    if ((RetVal == 0) && (ipFlag->verbose > 1)) {
      fprintf(stderr, "%s: ", progname);
      fprintf(stderr, _("Converted %u out of %u line breaks.\n"), converted, line_nr -1);
    }
    return RetVal;
}
#endif

/* converts stream ipInF to UNIX format text and write to stream ipOutF
 * RetVal: 0  if success
 *         -1  otherwise
 */
int ConvertDosToUnix(FILE* ipInF, FILE* ipOutF, CFlag *ipFlag, const char *progname)
{
    int RetVal = 0;
    int TempChar;
    int TempNextChar;
    int *ConvTable;
    unsigned int line_nr = 1;
    unsigned int converted = 0;
    char *errstr;

    ipFlag->status = 0;

    switch (ipFlag->ConvMode) {
      case CONVMODE_ASCII: /* ascii */
      case CONVMODE_UTF16LE: /* Assume UTF-16LE, bomtype = FILE_UTF8 or GB18030 */
      case CONVMODE_UTF16BE: /* Assume UTF-16BE, bomtype = FILE_UTF8 or GB18030 */
        ConvTable = D2UAsciiTable;
        break;
      case CONVMODE_7BIT: /* 7bit */
        ConvTable = D2U7BitTable;
        break;
      case CONVMODE_437: /* iso */
        ConvTable = D2UIso437Table;
        break;
      case CONVMODE_850: /* iso */
        ConvTable = D2UIso850Table;
        break;
      case CONVMODE_860: /* iso */
        ConvTable = D2UIso860Table;
        break;
      case CONVMODE_863: /* iso */
        ConvTable = D2UIso863Table;
        break;
      case CONVMODE_865: /* iso */
        ConvTable = D2UIso865Table;
        break;
      case CONVMODE_1252: /* iso */
        ConvTable = D2UIso1252Table;
        break;
      default: /* unknown convmode */
        ipFlag->status |= WRONG_CODEPAGE ;
        return(-1);
    }
    /* Turn off ISO and 7-bit conversion for Unicode text files */
    if (ipFlag->bomtype > 0)
      ConvTable = D2UAsciiTable;

    if ((ipFlag->ConvMode > CONVMODE_7BIT) && (ipFlag->verbose)) { /* not ascii or 7bit */
       fprintf(stderr, "%s: ", progname);
       fprintf(stderr, _("using code page %d.\n"), ipFlag->ConvMode);
    }

    /* CR-LF -> LF */
    /* LF    -> LF, in case the input file is a Unix text file */
    /* CR    -> CR, in dos2unix mode (don't modify Mac file) */
    /* CR    -> LF, in Mac mode */
    /* \x0a = Newline/Line Feed (LF) */
    /* \x0d = Carriage Return (CR) */

    switch (ipFlag->FromToMode) {
      case FROMTO_DOS2UNIX: /* dos2unix */
        while ((TempChar = fgetc(ipInF)) != EOF) {  /* get character */
          if ((ipFlag->Force == 0) &&
              (TempChar < 32) &&
              (TempChar != '\x0a') &&  /* Not an LF */
              (TempChar != '\x0d') &&  /* Not a CR */
              (TempChar != '\x09') &&  /* Not a TAB */
              (TempChar != '\x0c')) {  /* Not a form feed */
            RetVal = -1;
            ipFlag->status |= BINARY_FILE ;
            if (ipFlag->verbose) {
              if ((ipFlag->stdio_mode) && (!ipFlag->error)) ipFlag->error = 1;
              fprintf(stderr, "%s: ", progname);
              fprintf(stderr, _("Binary symbol 0x%02X found at line %u\n"),TempChar, line_nr);
            }
            break;
          }
          if (TempChar != '\x0d') {
            if (TempChar == '\x0a') /* Count all DOS and Unix line breaks */
              ++line_nr;
            if (fputc(ConvTable[TempChar], ipOutF) == EOF) {
              RetVal = -1;
              if (ipFlag->verbose) {
                ipFlag->error = errno;
                errstr = strerror(errno);
                fprintf(stderr, "%s: ", progname);
                fprintf(stderr, _("can not write to output file: %s\n"), errstr);
              }
              break;
            }
          } else {
            StripDelimiter( ipInF, ipOutF, ipFlag, TempChar, &converted);
          }
        }
        break;
      case FROMTO_MAC2UNIX: /* mac2unix */
        while ((TempChar = fgetc(ipInF)) != EOF) {
          if ((ipFlag->Force == 0) &&
              (TempChar < 32) &&
              (TempChar != '\x0a') &&  /* Not an LF */
              (TempChar != '\x0d') &&  /* Not a CR */
              (TempChar != '\x09') &&  /* Not a TAB */
              (TempChar != '\x0c')) {  /* Not a form feed */
            RetVal = -1;
            ipFlag->status |= BINARY_FILE ;
            if (ipFlag->verbose) {
              if ((ipFlag->stdio_mode) && (!ipFlag->error)) ipFlag->error = 1;
              fprintf(stderr, "%s: ", progname);
              fprintf(stderr, _("Binary symbol 0x%02X found at line %u\n"),TempChar, line_nr);
            }
            break;
          }
          if ((TempChar != '\x0d')) {
              if (TempChar == '\x0a') /* Count all DOS and Unix line breaks */
                ++line_nr;
              if(fputc(ConvTable[TempChar], ipOutF) == EOF) {
                RetVal = -1;
                if (ipFlag->verbose) {
                  ipFlag->error = errno;
                  errstr = strerror(errno);
                  fprintf(stderr, "%s: ", progname);
                  fprintf(stderr, _("can not write to output file: %s\n"), errstr);
                }
                break;
              }
            }
          else{
            /* TempChar is a CR */
            if ( (TempNextChar = fgetc(ipInF)) != EOF) {
              ungetc( TempNextChar, ipInF );  /* put back peek char */
              /* Don't touch this delimiter if it's a CR,LF pair. */
              if ( TempNextChar == '\x0a' ) {
                fputc('\x0d', ipOutF); /* put CR, part of DOS CR-LF */
                continue;
              }
            }
            if (fputc('\x0a', ipOutF) == EOF) { /* MAC line end (CR). Put LF */
                RetVal = -1;
                if (ipFlag->verbose) {
                  ipFlag->error = errno;
                  errstr = strerror(errno);
                  fprintf(stderr, "%s: ", progname);
                  fprintf(stderr, _("can not write to output file: %s\n"), errstr);
                }
                break;
              }
            converted++;
            line_nr++; /* Count all Mac line breaks */
            if (ipFlag->NewLine) {  /* add additional LF? */
              fputc('\x0a', ipOutF);
            }
          }
        }
        break;
      default: /* unknown FromToMode */
      ;
#if DEBUG
      fprintf(stderr, "%s: ", progname);
      fprintf(stderr, _("program error, invalid conversion mode %d\n"),ipFlag->FromToMode);
      exit(1);
#endif
    }
    if ((RetVal == 0) && (ipFlag->verbose > 1)) {
      fprintf(stderr, "%s: ", progname);
      fprintf(stderr, _("Converted %u out of %u line breaks.\n"),converted, line_nr -1);
    }
    return RetVal;
}


int main (int argc, char *argv[])
{
  /* variable declarations */
  char progname[9];
  CFlag *pFlag;
  char *ptr;
  char localedir[1024];
# ifdef __MINGW64__
  int _dowildcard = -1; /* enable wildcard expansion for Win64 */
# endif

  progname[8] = '\0';
  strcpy(progname,"dos2unix");

#ifdef ENABLE_NLS
   ptr = getenv("DOS2UNIX_LOCALEDIR");
   if (ptr == NULL)
      strcpy(localedir,LOCALEDIR);
   else {
      if (strlen(ptr) < sizeof(localedir))
         strcpy(localedir,ptr);
      else {
         fprintf(stderr,"%s: ",progname);
         fprintf(stderr, "%s", _("error: Value of environment variable DOS2UNIX_LOCALEDIR is too long.\n"));
         strcpy(localedir,LOCALEDIR);
      }
   }
#endif

#if defined(ENABLE_NLS) || (defined(D2U_UNICODE) && !defined(__MSDOS__) && !defined(_WIN32) && !defined(__OS2__))
/* setlocale() is also needed for nl_langinfo() */
   setlocale (LC_ALL, "");
#endif

#ifdef ENABLE_NLS
   bindtextdomain (PACKAGE, localedir);
   textdomain (PACKAGE);
#endif


  /* variable initialisations */
  pFlag = (CFlag*)malloc(sizeof(CFlag));
  pFlag->FromToMode = FROMTO_DOS2UNIX;  /* default dos2unix */
  pFlag->keep_bom = 0;

  if ( ((ptr=strrchr(argv[0],'/')) == NULL) && ((ptr=strrchr(argv[0],'\\')) == NULL) )
    ptr = argv[0];
  else
    ptr++;

  if ((strcmpi("mac2unix", ptr) == 0) || (strcmpi("mac2unix.exe", ptr) == 0)) {
    pFlag->FromToMode = FROMTO_MAC2UNIX;
    strcpy(progname,"mac2unix");
  }

#ifdef D2U_UNICODE
  return parse_options(argc, argv, pFlag, localedir, progname, PrintLicense, ConvertDosToUnix, ConvertDosToUnixW);
#else
  return parse_options(argc, argv, pFlag, localedir, progname, PrintLicense, ConvertDosToUnix);
#endif
}

