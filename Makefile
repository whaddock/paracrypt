###################################################################################
# DEFINES #########################################################################
###################################################################################
#
CUDA_PATH ?= /usr/local/cuda
CUDA_LIB ?= $(CUDA_PATH)/lib64
CUDA_INC ?= $(CUDA_PATH)/include
BOOST_PATH ?= /usr
BOOST_LIB ?= $(BOOST_PATH)/lib/boost
#
NVCC ?= $(CUDA_PATH)/bin/nvcc
CXX ?= g++
#
FLAGS ?= 
LIBS ?= "-L$(CUDA_LIB) -lcuda -lcudart"
INCL ?= "-I$(CUDA_INC)"
#
SRC_DIR ?= src
TST_DIR ?= $(SRC_DIR)/tests
BIN_DIR ?= bin
LIB_DIR ?= lib
OBJ_DIR ?= obj
#


###################################################################################
# OBJECTS #########################################################################
###################################################################################
#
AES.o: $(SRC_DIR)/AES.cpp
	$(CXX) $(FLAGS) -c $< -o $(OBJ_DIR)/$@
#
CudaAES.o: $(SRC_DIR)/CudaAES.cpp
	$(CXX) $(FLAGS) -c $< -o $(OBJ_DIR)/$@ $(INCL)
#
CudaEcbAes16B.o: $(SRC_DIR)/CudaEcbAes16B.cpp
	$(CXX) $(FLAGS) -c $< -o $(OBJ_DIR)/$@ $(INCL)
#
CudaEcbAes16B.cuo: $(SRC_DIR)/CudaEcbAes16B.cu
	$(NVCC) $(FLAGS) -c $< -o $(OBJ_DIR)/$@
#
GPUCipherDevice.o: $(SRC_DIR)/GPUCipherDevice.cpp
	$(CXX) $(FLAGS) -c $< -o $(OBJ_DIR)/$@
#
CUDACipherDevice.o: $(SRC_DIR)/CUDACipherDevice.cpp
	$(CXX) $(FLAGS) -c $< -o $(OBJ_DIR)/$@ $(INCL)
#
logging.o: $(SRC_DIR)/logging.cpp
	$(CXX) $(FLAGS) -c $< -o $(OBJ_DIR)/$@
#
AES_key_schedule.o: $(SRC_DIR)/openssl/AES_key_schedule.c
	$(CXX) $(FLAGS) -c $< -o $(OBJ_DIR)/$@

###################################################################################
# TESTS ###########################################################################
###################################################################################
#
tests.o: $(TST_DIR)/tests.cpp
	$(CXX) $(FLAGS) -c $< -o $(OBJ_DIR)/$@ $(INCL)
#	
tests: tests.o AES_key_schedule.o logging.o AES.o CudaAES.o CudaEcbAes16B.o  \
     CudaEcbAes16B.cuo GPUCipherDevice.o CUDACipherDevice.o \
	 $(CXX) $(FLAGS) $(OBJ_DIR)/tests.o $(OBJ_DIR)/AES_key_schedule.o \
	 $(OBJ_DIR)/AES.o $(OBJ_DIR)/CudaAES.o $(OBJ_DIR)/CudaEcbAes16B.o \
	 $(OBJ_DIR)/CudaEcbAes16B.cuo $(OBJ_DIR)/GPUCipherDevice.o $(OBJ_DIR)/CUDACipherDevice.o \
	 $(OBJ_DIR)/logging.o -o $(BIN_DIR)/paracrypt_tests $(LIBS)
#


###################################################################################
# BUILDS ##########################################################################
###################################################################################
#


###################################################################################
# MAKE ############################################################################
###################################################################################
#
clean: 
	rm -f $(OBJ_DIR)/*.o
	rm -f $(LIB_DIR)/*.a
	rm -f $(BIN_DIR)/*
	rm -f $(SRC_DIR)/*~
	rm -f $(SRC_DIR)/tests/*~
	rm -f $(SRC_DIR)/openssl/*~
#
all: tests
	
	# make icc
