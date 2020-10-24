# Copyright (C) 2017 GreenWaves Technologies
# All rights reserved.

# This software may be modified and distributed under the terms
# of the BSD license.  See the LICENSE file for details.

MODEL_SUFFIX?=

MODEL_PREFIX?=

# The training of the model is slightly different depending on
# the quantization. This is because in 8 bit mode we used signed
# 8 bit so the input to the model needs to be shifted 1 bit
ifeq ($(KWS_BITS),8)
  TRAIN_SUFFIX=_8BIT
else
  ifeq ($(KWS_BITS),16)
    TRAIN_SUFFIX=_16BIT
  else
    $(error Dont know how to build with this bit width)
  endif
endif

MODEL_PYTHON=python

# Increase this to improve accuracy
TRAINING_EPOCHS?=10
MODEL_TRAIN = model/training/train.py
MODEL_FREEZE = model/training/freeze.py
MODEL_BUILD = BUILD_MODEL$(MODEL_SUFFIX)
MODEL_TRAIN_BUILD = BUILD_TRAIN$(TRAIN_SUFFIX)
MODEL_TF = $(MODEL_TRAIN_BUILD)/conv.pbtxt
MODEL_TFLITE = $(MODEL_BUILD)/$(MODEL_PREFIX).tflite

TENSORS_DIR = $(MODEL_BUILD)/tensors
MODEL_TENSORS = $(MODEL_BUILD)/$(MODEL_PREFIX)_L3_Flash_Const.dat

MODEL_STATE = $(MODEL_BUILD)/$(MODEL_PREFIX).json
MODEL_SRC = $(MODEL_PREFIX)Model.c
MODEL_HEADER = $(MODEL_PREFIX)Info.h
MODEL_GEN = $(MODEL_BUILD)/$(MODEL_PREFIX)Kernels 
MODEL_GEN_C = $(addsuffix .c, $(MODEL_GEN))
MODEL_GEN_CLEAN = $(MODEL_GEN_C) $(addsuffix .h, $(MODEL_GEN))
MODEL_GEN_EXE = $(MODEL_BUILD)/GenTile

ifdef MODEL_QUANTIZED
  NNTOOL_EXTRA_FLAGS = -q
endif

MODEL_GENFLAGS_EXTRA =

EXTRA_GENERATOR_SRC =

$(info script $(NNTOOL_SCRIPT))
ifndef NNTOOL_SCRIPT
  NNTOOL_SCRIPT=model/nntool_script
endif
IMAGES = images
RM=rm -f

NNTOOL=nntool

NNTOOL_PATH = $(GAP_SDK_HOME)/tools/nntool
NNTOOL_KERNEL_PATH = $(NNTOOL_PATH)/autotiler/kernels
NNTOOL_GENERATOR_PATH = $(NNTOOL_PATH)/autotiler/generators
# Here we set the memory allocation for the generated kernels
# REMEMBER THAT THE L1 MEMORY ALLOCATION MUST INCLUDE SPACE
# FOR ALLOCATED STACKS!
MODEL_L1_MEMORY=52000
MODEL_L2_MEMORY=307200
MODEL_L3_MEMORY=8388608
# hram - HyperBus RAM
# qspiram - Quad SPI RAM
MODEL_L3_EXEC=hram
# hflash - HyperBus Flash
# qpsiflash - Quad SPI Flash
MODEL_L3_CONST=hflash
NNTOOL=nntool

NNTOOL_PATH = $(GAP_SDK_HOME)/tools/nntool
NNTOOL_KERNEL_PATH = $(NNTOOL_PATH)/autotiler/kernels
NNTOOL_GENERATOR_PATH = $(NNTOOL_PATH)/autotiler/generators

MODEL_LIB_POW2 += $(TILER_CNN_KERNEL_PATH)/CNN_BiasReLULinear_BasicKernels.c
MODEL_LIB_POW2 += $(TILER_CNN_KERNEL_PATH)/CNN_Conv_BasicKernels.c
MODEL_LIB_POW2 += $(TILER_CNN_KERNEL_PATH)/CNN_Conv_DP_BasicKernels.c
MODEL_LIB_POW2 += $(TILER_CNN_KERNEL_PATH)/CNN_Conv_DW_BasicKernels.c
MODEL_LIB_POW2 += $(TILER_CNN_KERNEL_PATH)/CNN_Conv_DW_DP_BasicKernels.c
MODEL_LIB_POW2 += $(TILER_CNN_KERNEL_PATH)/CNN_Pooling_BasicKernels.c
MODEL_LIB_POW2 += $(TILER_CNN_KERNEL_PATH)/CNN_MatAlgebra.c
MODEL_LIB_POW2 += $(TILER_CNN_KERNEL_PATH)/CNN_SoftMax.c
MODEL_LIB_POW2 += $(NNTOOL_KERNEL_PATH)/norm_transpose.c
MODEL_LIB_INCLUDE_POW2 = -I$(TILER_CNN_KERNEL_PATH) -I$(NNTOOL_KERNEL_PATH)
MODEL_GEN_POW2 += $(TILER_CNN_GENERATOR_PATH)/CNN_Generator_Util.c
MODEL_GEN_POW2 += $(TILER_CNN_GENERATOR_PATH)/CNN_Generators.c
MODEL_GEN_POW2 += $(NNTOOL_GENERATOR_PATH)/nntool_extra_generators.c
MODEL_GEN_INCLUDE_POW2 = -I$(TILER_CNN_GENERATOR_PATH) -I$(NNTOOL_GENERATOR_PATH)

MODEL_LIB_SQ8 += $(TILER_CNN_KERNEL_PATH_SQ8)/CNN_Activation_SQ8.c
MODEL_LIB_SQ8 += $(TILER_CNN_KERNEL_PATH_SQ8)/CNN_Bias_Linear_SQ8.c
MODEL_LIB_SQ8 += $(TILER_CNN_KERNEL_PATH_SQ8)/CNN_Conv_SQ8.c
MODEL_LIB_SQ8 += $(TILER_CNN_KERNEL_PATH_SQ8)/CNN_Pooling_SQ8.c
MODEL_LIB_SQ8 += $(TILER_CNN_KERNEL_PATH_SQ8)/CNN_Conv_DW_SQ8.c
MODEL_LIB_SQ8 += $(TILER_CNN_KERNEL_PATH_SQ8)/CNN_MatAlgebra_SQ8.c
MODEL_LIB_SQ8 += $(TILER_CNN_KERNEL_PATH_SQ8)/CNN_SoftMax_SQ8.c
MODEL_LIB_SQ8 += $(TILER_CNN_KERNEL_PATH_SQ8)/CNN_AT_Misc.c
MODEL_LIB_SQ8 += $(TILER_CNN_KERNEL_PATH_SQ8)/RNN_SQ8.c
MODEL_LIB_SQ8 += $(NNTOOL_KERNEL_PATH)/norm_transpose.c
MODEL_LIB_INCLUDE_SQ8 = -I$(TILER_CNN_KERNEL_PATH) -I$(TILER_CNN_KERNEL_PATH_SQ8) -I$(NNTOOL_KERNEL_PATH)
MODEL_GEN_SQ8 += $(TILER_CNN_GENERATOR_PATH)/CNN_Generator_Util.c
MODEL_GEN_SQ8 += $(TILER_CNN_GENERATOR_PATH_SQ8)/CNN_Generators_SQ8.c
MODEL_GEN_SQ8 += $(TILER_CNN_GENERATOR_PATH_SQ8)/RNN_Generators_SQ8.c
MODEL_GEN_SQ8 += $(NNTOOL_GENERATOR_PATH)/nntool_extra_generators.c
MODEL_GEN_INCLUDE_SQ8 = -I$(TILER_CNN_GENERATOR_PATH) -I$(TILER_CNN_GENERATOR_PATH_SQ8) -I$(NNTOOL_GENERATOR_PATH)


MODEL_SIZE_CFLAGS = -DAT_INPUT_HEIGHT=$(AT_INPUT_HEIGHT) -DAT_INPUT_WIDTH=$(AT_INPUT_WIDTH) -DAT_INPUT_COLORS=$(AT_INPUT_COLORS)

ifdef MODEL_SQ8
  CNN_GEN = $(MODEL_GEN_SQ8)
  CNN_GEN_INCLUDE = $(MODEL_GEN_INCLUDE_SQ8)
  CNN_LIB = $(MODEL_LIB_SQ8)
  CNN_LIB_INCLUDE = $(MODEL_LIB_INCLUDE_SQ8)
else
  CNN_GEN = $(MODEL_GEN_POW2)
  CNN_GEN_INCLUDE = $(MODEL_GEN_INCLUDE_POW2)
  CNN_LIB = $(MODEL_LIB_POW2)
  CNN_LIB_INCLUDE = $(MODEL_LIB_INCLUDE_POW2)
endif
$(info GEN ... $(CNN_GEN))
