# === Project Settings ===
TARGET   = main.exe
SRCDIR   = src
INCDIR   = include
BINDIR   = bin
FWDIR    = firmware

# === Tools ===
CC       = gcc
CXX      = g++
AR       = ar
RM       = rm -f

# === File Extensions ===
CEXTS    = c
CXXEXTS  = cpp cc c++

# === Base Flags ===
WARN     = -Wall -Wextra -MMD -MP

CFLAGS_DEBUG   = $(WARN) -O0 -g
CFLAGS_RELEASE = $(WARN) -O2 -DNDEBUG

CXXFLAGS_DEBUG   = $(WARN) -std=c++20 -O0 -g
CXXFLAGS_RELEASE = $(WARN) -std=c++20 -O2 -DNDEBUG

LDFLAGS  =
LIBS     = $(wildcard $(FWDIR)/*.a)

# === Sources & Objects ===
CSRC     = $(wildcard $(SRCDIR)/*.$(CEXTS))
CXXSRC   = $(wildcard $(SRCDIR)/*.$(CXXEXTS))

COBJ     = $(patsubst $(SRCDIR)/%,$(BINDIR)/%,$(CSRC:.c=.o))
CXXOBJ   = $(patsubst $(SRCDIR)/%,$(BINDIR)/%,$(CXXSRC:.cpp=.o))
OBJ      = $(COBJ) $(CXXOBJ)

DEPS     = $(OBJ:.o=.d)

# === Default Build Type ===
BUILD    ?= release

ifeq ($(BUILD),debug)
  CFLAGS   = $(CFLAGS_DEBUG)
  CXXFLAGS = $(CXXFLAGS_DEBUG)
else ifeq ($(BUILD),release)
  CFLAGS   = $(CFLAGS_RELEASE)
  CXXFLAGS = $(CXXFLAGS_RELEASE)
else
  $(error Unknown BUILD type: $(BUILD). Use 'debug' or 'release')
endif

# === Targets ===
all: $(TARGET)

debug:
	$(MAKE) BUILD=debug

release:
	$(MAKE) BUILD=release

$(TARGET): $(OBJ) $(LIBS)
	$(CXX) $(OBJ) -o $@ $(LDFLAGS) $(LIBS)

$(BINDIR)/%.o: $(SRCDIR)/%.c | $(BINDIR)
	$(CC) $(CFLAGS) -I$(INCDIR) -c $< -o $@

$(BINDIR)/%.o: $(SRCDIR)/%.cpp | $(BINDIR)
	$(CXX) $(CXXFLAGS) -I$(INCDIR) -c $< -o $@

$(BINDIR):
	mkdir -p $(BINDIR)

clean:
	$(RM) $(BINDIR)/*.o $(BINDIR)/*.d $(TARGET)

-include $(DEPS)

.PHONY: all clean debug release
# === End of Makefile ===
