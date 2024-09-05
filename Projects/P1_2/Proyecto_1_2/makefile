CC := as
LD := ld

SRC := Proyecto_1_2.s
OBJ := $(SRC:.s=.o)
TARGET := Proyecto_1_2

all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) -o $@ $<

$(OBJ): $(SRC)
	$(CC) -o $@ $<

clean:
	rm -f $(OBJ) $(TARGET)
