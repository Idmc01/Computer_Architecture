CC := as
LD := ld

SRC := Tarea_Programada_2.s
OBJ := $(SRC:.s=.o)
TARGET := Tarea_Programada_2

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -o $@ $<

$(OBJ): $(SRC)
	$(CC) -o $@ $<

clean:
	rm -f $(OBJ) $(TARGET)
