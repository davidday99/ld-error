PROJECT = main
DEV = /dev/ttyACM0
FLASHER = lm4flash
SRCS = $(wildcard src/*.c)
OBJ = obj/
OBJS = $(addprefix $(OBJ), $(notdir $(SRCS:.c=.o)))
INC = inc/
LD_SCRIPT = TM4C123GH6PM.ld

CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld 
DEBUGGER = arm-none-eabi-gdb
OBJCOPY = arm-none-eabi-objcopy
RM = rm -rf
MKDIR = @mkdir -p $(@D)

CFLAGS = -ggdb3 -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 
CFLAGS += -mfloat-abi=softfp -MD -std=c99 -Wextra -Wall -Wno-missing-braces
DEPFLAGS = -MT $@ -MMD -MP

all: bin/$(PROJECT).elf

$(OBJ)%.o: src/%.c          
	$(MKDIR)              
	$(CC) -o $@ $< -c -I$(INC) $(CFLAGS) $(DEPFLAGS)
	
bin/$(PROJECT).elf: $(OBJS) 
	$(MKDIR)           
	$(CC) -o $@ $^ $(CFLAGS) $(DEPFLAGS) -Wl,-T$(LD_SCRIPT) -Wl,-eReset_Handler
	$(OBJCOPY) -O binary $@ bin/$(PROJECT).bin 

flash:
	$(FLASHER) -S $(DEV) bin/$(PROJECT).bin

debug:
	$(DEBUGGER) --tui bin/$(PROJECT).elf -ex "target remote :3333" -ex "monitor reset halt"

-include $(OBJS:.o=.d)

clean:
	-$(RM) obj
	-$(RM) bin