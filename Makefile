PROJECT=main

SRCS=$(wildcard src/*.c) \
		 $(wildcard src/*.S) \
		 $(wildcard src/*.s) \
		 gcc/startup_gcc.c \
		 gcc/intrinsics.s
OBJ=obj
OBJS=$(addprefix $(OBJ)/, \
	   $(filter-out %.c %.S,$(SRCS:.s=.o)) \
	   $(filter-out %.s %.S, $(SRCS:.c=.o)) \
	   $(filter-out %.c %.s, $(SRCS:.S=.o)))
BIN=build
INC= -Iinc

LD_SCRIPT=gcc/TM4C123GH6PM.ld 
DEV=/dev/ttyACM0
FLASHER=lm4flash

CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

CFLAGS = -g -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -nostdlib -ffreestanding
CFLAGS += -mfloat-abi=hard -std=c99 -Wextra -Wall -Wno-missing-braces
LDFLAGS = -Wl,-T$(LD_SCRIPT) -Wl,-eResetISR -Llib -Wl,-l:libdriver.a
DEPFLAGS = -MT $@ -MMD -MP

RM = rm -rf
MKDIR = @mkdir -p $(@D)

all: $(BIN)/$(PROJECT).elf $(BIN)/$(PROJECT).bin

clean:
	-$(RM) $(OBJ) 
	-$(RM) $(BIN) 

$(OBJ)/%.o: %.c          
	$(MKDIR)              
	$(CC) -o $@ $< -c $(INC) $(CFLAGS) $(DEPFLAGS)
	
$(OBJ)/%.o: %.s          
	$(MKDIR)              
	$(CC) -o $@ $< -c $(INC) $(CFLAGS) $(DEPFLAGS)

$(OBJ)/%.o: %.S          
	$(MKDIR)              
	$(CC) -o $@ $< -c $(INC) $(CFLAGS) $(DEPFLAGS)

$(BIN)/$(PROJECT).elf: $(OBJS) 
	$(MKDIR)           
	$(CC) -o $@ $^ $(INC) $(CFLAGS) $(DEPFLAGS) $(LDFLAGS)

$(BIN)/$(PROJECT).bin: $(BIN)/$(PROJECT).elf
	$(OBJCOPY) -O binary $< $@

flash: $(BIN)/$(PROJECT).bin
	$(FLASHER) -S $(DEV) bin/$(PROJECT).bin

-include $(OBJS:.o=.d)

.PHONY: all clean

