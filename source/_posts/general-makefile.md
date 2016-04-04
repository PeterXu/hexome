title: 修改版通用Makefile模板
tags: []
categories:
  - 技术
date: 2009-03-09 16:15:00
---
对一个已有的通用Makefile模板(来自whyglinux)作了部分修改，供自己使用。

```
###############################################################################
#
# Generic Makefile for C/C++ Program
#
# Author: whyglinux (whyglinux AT hotmail DOT com)
# Date: 2006/03/04
# Modified: uskee@hotmail.com at 2009/03/09


# Description:
# The makefile searches in directories for the source files
# with extensions specified in , then compiles the sources
# and finally produces the , the executable file, by linking
# the objectives.
# Usage:
# $ make compile and link the program.
# $ make objs compile only (no linking. Rarely used).
# $ make clean clean the objectives and dependencies.
# $ make cleanall clean the objectives, dependencies and executable.
# $ make rebuild rebuild the program. The same as make clean && make all.
#==============================================================================
## Customizing Section: adjust the following if necessary.
##=============================================================================
# The generated file name.
# It must be specified.
# PROGRAM := a.out # the generated name
PROGRAM :=
# The directories in which source files reside.
# At least one path should be specified.
# SRCDIRS := . # current directory
SRCDIRS := .
# The source file types (headers excluded).
# At least one type should be specified.
# The valid suffixes are among of .c, .C, .cc, .cpp, .CPP, .c++, .cp, or .cxx.
# SRCEXTS := .c # C program
# SRCEXTS := .cpp # C++ program
# SRCEXTS := .c .cpp # C/C++ program
SRCEXTS := .c .cpp
# The flags used by the cpp (man cpp for more).
# CPPFLAGS := -Wall -Werror # show all warnings and take them as errors
CPPFLAGS := -Wall -Werror -Wno-deprecated
# The compiling flags used only for C.
# If it is a C++ program, no need to set these flags.
# If it is a C and C++ merging program, set these flags for the C parts.
CFLAGS :=
CFLAGS +=
# The compiling flags used only for C++.
# If it is a C program, no need to set these flags.
# If it is a C and C++ merging program, set these flags for the C++ parts.
CXXFLAGS :=
CXXFLAGS +=
# The directories contains all required headers; “-I”
INCLUDES :=
INCLUDES +=
# The library and the link options ( C and C++ common).: “-L” and “-l”
# If for generating dynamic libraries, using “-shared” option, or no.
LDFLAGS :=
LDFLAGS +=
#==============================================================================
## Implict Section: change the following only when necessary.
##=============================================================================
# The C program compiler. Uncomment it to specify yours explicitly.
CC = gcc
# The C++ program compiler. Uncomment it to specify yours explicitly.
CXX = g++
# Uncomment the 2 lines to compile C programs as C++ ones.
#CC = $(CXX)
#CFLAGS = $(CXXFLAGS)
# The command used to generate static library
AR	= ar rcs
# The command used to delete file.
RM	= rm -f
#==============================================================================
## Stable Section: usually no need to be changed. But you can add more.
##=============================================================================
SHELL = /bin/sh
SOURCES = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
OBJS = $(foreach x,$(SRCEXTS), \
$(patsubst %$(x),%.o,$(filter %$(x),$(SOURCES))))
DEPS = $(patsubst %.o,%.d,$(OBJS))
.PHONY : all objs clean cleanall rebuild
#—————————————————
# Rules for creating the dependency files (.d).
#—————————————————
all : $(PROGRAM)
%.d : %.c
@$(CC) -MM -MD $(CFLAGS) $(INCLUDES) $<
%.d : %.cc
@$(CC) -MM -MD $(CXXFLAGS) $(INCLUDES) $<
%.d : %.cpp
@$(CC) -MM -MD $(CXXFLAGS) $(INCLUDES) $<
#---------------------------------------------------
# Rules for producing the objects.
#---------------------------------------------------
objs : $(OBJS)
%.o : %.c
$(CC) -c $(CPPFLAGS) $(CFLAGS) $(INCLUDES) $<
%.o : %.cc
$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) $<
%.o : %.cpp
$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $(INCLUDES) $<
#---------------------------------------------------
# Rules for producing the executable.
#----------------------------------------------
$(PROGRAM) : $(OBJS)
# This is for generating executal program or dynamic library
ifeq ($(strip $(SRCEXTS)), ".c") # C file
$(CC) -o $(PROGRAM) $(OBJS) $(LDFLAGS)
else # C++ file
$(CXX) -o $(PROGRAM) $(OBJS) $(LDFLAGS)
endif
# This is for generation static libraries.
# $(AR)	$(PROGRAM)	$(OBJS)
-include $(DEPS)
rebuild: clean all
clean :
@$(RM) *.o *.d
cleanall: clean
@$(RM) $(PROGRAM) $(PROGRAM).a $(PROGRAM).so
### End of the Makefile ## Suggestions are welcome ## All rights reserved ###
###############################################################################
```
