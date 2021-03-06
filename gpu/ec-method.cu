/*
  Copyright (c) 2012-2014 DataLab, s.l. <http://www.datalab.es>
  This file is part of GlusterFS.

  This file is licensed to you under your choice of the GNU Lesser
  General Public License, version 3 or any later version (LGPLv3 or
  later), or the GNU General Public License, version 2 (GPLv2), in all
  cases as published by the Free Software Foundation.
*/
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include <pthread.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include "ec-method.h"

__constant__ uint8_t GfPow_cuda[EC_GF_SIZE << 1]={1,2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,173,71,142,1,2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,173,71,142,1,0};
__constant__ uint8_t GfLog_cuda[EC_GF_SIZE << 1] = {0,255,1,25,2,50,26,198,3,223,51,238,27,104,199,75,4,100,224,14,52,141,239,129,28,193,105,248,200,8,76,113,5,138,101,47,225,36,15,33,53,147,142,218,240,18,130,69,29,181,194,125,106,39,249,185,201,154,9,120,77,228,114,166,6,191,139,98,102,221,48,253,226,152,37,179,16,145,34,136,54,208,148,206,143,150,219,189,241,210,19,92,131,56,70,64,30,66,182,163,195,72,126,110,107,58,40,84,250,133,186,61,202,94,155,159,10,21,121,43,78,212,229,172,115,243,167,87,7,112,192,247,140,128,99,13,103,74,222,237,49,197,254,24,227,165,153,119,38,184,180,124,17,68,146,217,35,32,137,46,55,63,209,91,149,188,207,205,144,135,151,178,220,252,190,97,242,86,211,171,20,42,93,158,132,60,57,83,71,109,65,162,31,45,67,216,183,123,164,118,196,23,73,236,127,12,111,246,108,161,59,82,41,157,85,170,251,96,134,177,187,204,62,90,203,89,95,176,156,169,160,81,11,245,22,235,122,117,44,215,79,174,213,233,230,231,173,232,116,214,244,234,168,80,88,175,255,1,25,2,50,26,198,3,223,51,238,27,104,199,75,4,100,224,14,52,141,239,129,28,193,105,248,200,8,76,113,5,138,101,47,225,36,15,33,53,147,142,218,240,18,130,69,29,181,194,125,106,39,249,185,201,154,9,120,77,228,114,166,6,191,139,98,102,221,48,253,226,152,37,179,16,145,34,136,54,208,148,206,143,150,219,189,241,210,19,92,131,56,70,64,30,66,182,163,195,72,126,110,107,58,40,84,250,133,186,61,202,94,155,159,10,21,121,43,78,212,229,172,115,243,167,87,7,112,192,247,140,128,99,13,103,74,222,237,49,197,254,24,227,165,153,119,38,184,180,124,17,68,146,217,35,32,137,46,55,63,209,91,149,188,207,205,144,135,151,178,220,252,190,97,242,86,211,171,20,42,93,158,132,60,57,83,71,109,65,162,31,45,67,216,183,123,164,118,196,23,73,236,127,12,111,246,108,161,59,82,41,157,85,170,251,96,134,177,187,204,62,90,203,89,95,176,156,169,160,81,11,245,22,235,122,117,44,215,79,174,213,233,230,231,173,232,116,214,244,234,168,80,88,175,0};

__constant__ uint8_t bitmatrix[255][8]={
		{1,2,4,8,16,32,64,128},
		{128,1,130,132,136,16,32,64},
		{129,3,134,140,152,48,96,192},
		{64,128,65,194,196,136,16,32},
		{65,130,69,202,212,168,80,160},
		{192,129,195,70,76,152,48,96},
		{193,131,199,78,92,184,112,224},
		{32,64,160,97,226,196,136,16},
		{33,66,164,105,242,228,200,144},
		{160,65,34,229,106,212,168,80},
		{161,67,38,237,122,244,232,208},
		{96,192,225,163,38,76,152,48},
		{97,194,229,171,54,108,216,176},
		{224,193,99,39,174,92,184,112},
		{225,195,103,47,190,124,248,240},
		{16,32,80,176,113,226,196,136},
		{17,34,84,184,97,194,132,8},
		{144,33,210,52,249,242,228,200},
		{145,35,214,60,233,210,164,72},
		{80,160,17,114,181,106,212,168},
		{81,162,21,122,165,74,148,40},
		{208,161,147,246,61,122,244,232},
		{209,163,151,254,45,90,180,104},
		{48,96,240,209,147,38,76,152},
		{49,98,244,217,131,6,12,24},
		{176,97,114,85,27,54,108,216},
		{177,99,118,93,11,22,44,88},
		{112,224,177,19,87,174,92,184},
		{113,226,181,27,71,142,28,56},
		{240,225,51,151,223,190,124,248},
		{241,227,55,159,207,158,60,120},
		{136,16,168,216,56,113,226,196},
		{137,18,172,208,40,81,162,68},
		{8,17,42,92,176,97,194,132},
		{9,19,46,84,160,65,130,4},
		{200,144,233,26,252,249,242,228},
		{201,146,237,18,236,217,178,100},
		{72,145,107,158,116,233,210,164},
		{73,147,111,150,100,201,146,36},
		{168,80,8,185,218,181,106,212},
		{169,82,12,177,202,149,42,84},
		{40,81,138,61,82,165,74,148},
		{41,83,142,53,66,133,10,20},
		{232,208,73,123,30,61,122,244},
		{233,210,77,115,14,29,58,116},
		{104,209,203,255,150,45,90,180},
		{105,211,207,247,134,13,26,52},
		{152,48,248,104,73,147,38,76},
		{153,50,252,96,89,179,102,204},
		{24,49,122,236,193,131,6,12},
		{25,51,126,228,209,163,70,140},
		{216,176,185,170,141,27,54,108},
		{217,178,189,162,157,59,118,236},
		{88,177,59,46,5,11,22,44},
		{89,179,63,38,21,43,86,172},
		{184,112,88,9,171,87,174,92},
		{185,114,92,1,187,119,238,220},
		{56,113,218,141,35,71,142,28},
		{57,115,222,133,51,103,206,156},
		{248,240,25,203,111,223,190,124},
		{249,242,29,195,127,255,254,252},
		{120,241,155,79,231,207,158,60},
		{121,243,159,71,247,239,222,188},
		{196,136,212,108,28,56,113,226},
		{197,138,208,100,12,24,49,98},
		{68,137,86,232,148,40,81,162},
		{69,139,82,224,132,8,17,34},
		{132,8,149,174,216,176,97,194},
		{133,10,145,166,200,144,33,66},
		{4,9,23,42,80,160,65,130},
		{5,11,19,34,64,128,1,2},
		{228,200,116,13,254,252,249,242},
		{229,202,112,5,238,220,185,114},
		{100,201,246,137,118,236,217,178},
		{101,203,242,129,102,204,153,50},
		{164,72,53,207,58,116,233,210},
		{165,74,49,199,42,84,169,82},
		{36,73,183,75,178,100,201,146},
		{37,75,179,67,162,68,137,18},
		{212,168,132,220,109,218,181,106},
		{213,170,128,212,125,250,245,234},
		{84,169,6,88,229,202,149,42},
		{85,171,2,80,245,234,213,170},
		{148,40,197,30,169,82,165,74},
		{149,42,193,22,185,114,229,202},
		{20,41,71,154,33,66,133,10},
		{21,43,67,146,49,98,197,138},
		{244,232,36,189,143,30,61,122},
		{245,234,32,181,159,62,125,250},
		{116,233,166,57,7,14,29,58},
		{117,235,162,49,23,46,93,186},
		{180,104,101,127,75,150,45,90},
		{181,106,97,119,91,182,109,218},
		{52,105,231,251,195,134,13,26},
		{53,107,227,243,211,166,77,154},
		{76,152,124,180,36,73,147,38},
		{77,154,120,188,52,105,211,166},
		{204,153,254,48,172,89,179,102},
		{205,155,250,56,188,121,243,230},
		{12,24,61,118,224,193,131,6},
		{13,26,57,126,240,225,195,134},
		{140,25,191,242,104,209,163,70},
		{141,27,187,250,120,241,227,198},
		{108,216,220,213,198,141,27,54},
		{109,218,216,221,214,173,91,182},
		{236,217,94,81,78,157,59,118},
		{237,219,90,89,94,189,123,246},
		{44,88,157,23,2,5,11,22},
		{45,90,153,31,18,37,75,150},
		{172,89,31,147,138,21,43,86},
		{173,91,27,155,154,53,107,214},
		{92,184,44,4,85,171,87,174},
		{93,186,40,12,69,139,23,46},
		{220,185,174,128,221,187,119,238},
		{221,187,170,136,205,155,55,110},
		{28,56,109,198,145,35,71,142},
		{29,58,105,206,129,3,7,14},
		{156,57,239,66,25,51,103,206},
		{157,59,235,74,9,19,39,78},
		{124,248,140,101,183,111,223,190},
		{125,250,136,109,167,79,159,62},
		{252,249,14,225,63,127,255,254},
		{253,251,10,233,47,95,191,126},
		{60,120,205,167,115,231,207,158},
		{61,122,201,175,99,199,143,30},
		{188,121,79,35,251,247,239,222},
		{189,123,75,43,235,215,175,94},
		{226,196,106,54,142,28,56,113},
		{227,198,110,62,158,60,120,241},
		{98,197,232,178,6,12,24,49},
		{99,199,236,186,22,44,88,177},
		{162,68,43,244,74,148,40,81},
		{163,70,47,252,90,180,104,209},
		{34,69,169,112,194,132,8,17},
		{35,71,173,120,210,164,72,145},
		{194,132,202,87,108,216,176,97},
		{195,134,206,95,124,248,240,225},
		{66,133,72,211,228,200,144,33},
		{67,135,76,219,244,232,208,161},
		{130,4,139,149,168,80,160,65},
		{131,6,143,157,184,112,224,193},
		{2,5,9,17,32,64,128,1},
		{3,7,13,25,48,96,192,129},
		{242,228,58,134,255,254,252,249},
		{243,230,62,142,239,222,188,121},
		{114,229,184,2,119,238,220,185},
		{115,231,188,10,103,206,156,57},
		{178,100,123,68,59,118,236,217},
		{179,102,127,76,43,86,172,89},
		{50,101,249,192,179,102,204,153},
		{51,103,253,200,163,70,140,25},
		{210,164,154,231,29,58,116,233},
		{211,166,158,239,13,26,52,105},
		{82,165,24,99,149,42,84,169},
		{83,167,28,107,133,10,20,41},
		{146,36,219,37,217,178,100,201},
		{147,38,223,45,201,146,36,73},
		{18,37,89,161,81,162,68,137},
		{19,39,93,169,65,130,4,9},
		{106,212,194,238,182,109,218,181},
		{107,214,198,230,166,77,154,53},
		{234,213,64,106,62,125,250,245},
		{235,215,68,98,46,93,186,117},
		{42,84,131,44,114,229,202,149},
		{43,86,135,36,98,197,138,21},
		{170,85,1,168,250,245,234,213},
		{171,87,5,160,234,213,170,85},
		{74,148,98,143,84,169,82,165},
		{75,150,102,135,68,137,18,37},
		{202,149,224,11,220,185,114,229},
		{203,151,228,3,204,153,50,101},
		{10,20,35,77,144,33,66,133},
		{11,22,39,69,128,1,2,5},
		{138,21,161,201,24,49,98,197},
		{139,23,165,193,8,17,34,69},
		{122,244,146,94,199,143,30,61},
		{123,246,150,86,215,175,94,189},
		{250,245,16,218,79,159,62,125},
		{251,247,20,210,95,191,126,253},
		{58,116,211,156,3,7,14,29},
		{59,118,215,148,19,39,78,157},
		{186,117,81,24,139,23,46,93},
		{187,119,85,16,155,55,110,221},
		{90,180,50,63,37,75,150,45},
		{91,182,54,55,53,107,214,173},
		{218,181,176,187,173,91,182,109},
		{219,183,180,179,189,123,246,237},
		{26,52,115,253,225,195,134,13},
		{27,54,119,245,241,227,198,141},
		{154,53,241,121,105,211,166,77},
		{155,55,245,113,121,243,230,205},
		{38,76,190,90,146,36,73,147},
		{39,78,186,82,130,4,9,19},
		{166,77,60,222,26,52,105,211},
		{167,79,56,214,10,20,41,83},
		{102,204,255,152,86,172,89,179},
		{103,206,251,144,70,140,25,51},
		{230,205,125,28,222,188,121,243},
		{231,207,121,20,206,156,57,115},
		{6,12,30,59,112,224,193,131},
		{7,14,26,51,96,192,129,3},
		{134,13,156,191,248,240,225,195},
		{135,15,152,183,232,208,161,67},
		{70,140,95,249,180,104,209,163},
		{71,142,91,241,164,72,145,35},
		{198,141,221,125,60,120,241,227},
		{199,143,217,117,44,88,177,99},
		{54,108,238,234,227,198,141,27},
		{55,110,234,226,243,230,205,155},
		{182,109,108,110,107,214,173,91},
		{183,111,104,102,123,246,237,219},
		{118,236,175,40,39,78,157,59},
		{119,238,171,32,55,110,221,187},
		{246,237,45,172,175,94,189,123},
		{247,239,41,164,191,126,253,251},
		{22,44,78,139,1,2,5,11},
		{23,46,74,131,17,34,69,139},
		{150,45,204,15,137,18,37,75},
		{151,47,200,7,153,50,101,203},
		{86,172,15,73,197,138,21,43},
		{87,174,11,65,213,170,85,171},
		{214,173,141,205,77,154,53,107},
		{215,175,137,197,93,186,117,235},
		{174,92,22,130,170,85,171,87},
		{175,94,18,138,186,117,235,215},
		{46,93,148,6,34,69,139,23},
		{47,95,144,14,50,101,203,151},
		{238,220,87,64,110,221,187,119},
		{239,222,83,72,126,253,251,247},
		{110,221,213,196,230,205,155,55},
		{111,223,209,204,246,237,219,183},
		{142,28,182,227,72,145,35,71},
		{143,30,178,235,88,177,99,199},
		{14,29,52,103,192,129,3,7},
		{15,31,48,111,208,161,67,135},
		{206,156,247,33,140,25,51,103},
		{207,158,243,41,156,57,115,231},
		{78,157,117,165,4,9,19,39},
		{79,159,113,173,20,41,83,167},
		{190,124,70,50,219,183,111,223},
		{191,126,66,58,203,151,47,95},
		{62,125,196,182,83,167,79,159},
		{63,127,192,190,67,135,15,31},
		{254,252,7,240,31,63,127,255},
		{255,254,3,248,15,31,63,127},
		{126,253,133,116,151,47,95,191},
		{127,255,129,124,135,15,31,63},
		{158,60,230,83,57,115,231,207},
		{159,62,226,91,41,83,167,79},
		{30,61,100,215,177,99,199,143},
		{31,63,96,223,161,67,135,15},
		{222,188,167,145,253,251,247,239},
		{223,190,163,153,237,219,183,111},
		{94,189,37,21,117,235,215,175},
		{95,191,33,29,101,203,151,47},
};


__constant__ uint8_t inverse[64*(64+1)];


uint32_t GfPow[EC_GF_SIZE << 1]={1,2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,173,71,142,1,2,4,8,16,32,64,128,29,58,116,232,205,135,19,38,76,152,45,90,180,117,234,201,143,3,6,12,24,48,96,192,157,39,78,156,37,74,148,53,106,212,181,119,238,193,159,35,70,140,5,10,20,40,80,160,93,186,105,210,185,111,222,161,95,190,97,194,153,47,94,188,101,202,137,15,30,60,120,240,253,231,211,187,107,214,177,127,254,225,223,163,91,182,113,226,217,175,67,134,17,34,68,136,13,26,52,104,208,189,103,206,129,31,62,124,248,237,199,147,59,118,236,197,151,51,102,204,133,23,46,92,184,109,218,169,79,158,33,66,132,21,42,84,168,77,154,41,82,164,85,170,73,146,57,114,228,213,183,115,230,209,191,99,198,145,63,126,252,229,215,179,123,246,241,255,227,219,171,75,150,49,98,196,149,55,110,220,165,87,174,65,130,25,50,100,200,141,7,14,28,56,112,224,221,167,83,166,81,162,89,178,121,242,249,239,195,155,43,86,172,69,138,9,18,36,72,144,61,122,244,245,247,243,251,235,203,139,11,22,44,88,176,125,250,233,207,131,27,54,108,216,173,71,142,1,0};
uint32_t GfLog[EC_GF_SIZE << 1] = {256,255,1,25,2,50,26,198,3,223,51,238,27,104,199,75,4,100,224,14,52,141,239,129,28,193,105,248,200,8,76,113,5,138,101,47,225,36,15,33,53,147,142,218,240,18,130,69,29,181,194,125,106,39,249,185,201,154,9,120,77,228,114,166,6,191,139,98,102,221,48,253,226,152,37,179,16,145,34,136,54,208,148,206,143,150,219,189,241,210,19,92,131,56,70,64,30,66,182,163,195,72,126,110,107,58,40,84,250,133,186,61,202,94,155,159,10,21,121,43,78,212,229,172,115,243,167,87,7,112,192,247,140,128,99,13,103,74,222,237,49,197,254,24,227,165,153,119,38,184,180,124,17,68,146,217,35,32,137,46,55,63,209,91,149,188,207,205,144,135,151,178,220,252,190,97,242,86,211,171,20,42,93,158,132,60,57,83,71,109,65,162,31,45,67,216,183,123,164,118,196,23,73,236,127,12,111,246,108,161,59,82,41,157,85,170,251,96,134,177,187,204,62,90,203,89,95,176,156,169,160,81,11,245,22,235,122,117,44,215,79,174,213,233,230,231,173,232,116,214,244,234,168,80,88,175,255,1,25,2,50,26,198,3,223,51,238,27,104,199,75,4,100,224,14,52,141,239,129,28,193,105,248,200,8,76,113,5,138,101,47,225,36,15,33,53,147,142,218,240,18,130,69,29,181,194,125,106,39,249,185,201,154,9,120,77,228,114,166,6,191,139,98,102,221,48,253,226,152,37,179,16,145,34,136,54,208,148,206,143,150,219,189,241,210,19,92,131,56,70,64,30,66,182,163,195,72,126,110,107,58,40,84,250,133,186,61,202,94,155,159,10,21,121,43,78,212,229,172,115,243,167,87,7,112,192,247,140,128,99,13,103,74,222,237,49,197,254,24,227,165,153,119,38,184,180,124,17,68,146,217,35,32,137,46,55,63,209,91,149,188,207,205,144,135,151,178,220,252,190,97,242,86,211,171,20,42,93,158,132,60,57,83,71,109,65,162,31,45,67,216,183,123,164,118,196,23,73,236,127,12,111,246,108,161,59,82,41,157,85,170,251,96,134,177,187,204,62,90,203,89,95,176,156,169,160,81,11,245,22,235,122,117,44,215,79,174,213,233,230,231,173,232,116,214,244,234,168,80,88,175,0};



static uint32_t ec_method_mul(uint32_t a, uint32_t b)
{
    if (a && b)
    {
        return GfPow[GfLog[a] + GfLog[b]];
    }

    return 0;
}
static uint32_t ec_method_div(uint32_t a, uint32_t b)
{
    if (b)
    {
        if (a)
        {
            return GfPow[EC_GF_SIZE - 1 + GfLog[a] - GfLog[b]];
        }
        return 0;
    }
    return EC_GF_SIZE;
}





__global__ void encode_batch_kernel(uint32_t columns,uint32_t total_rows,uint8_t* cuda_in,uint8_t *cuda_out,size_t size){

	int row = blockIdx.y *blockDim.y + threadIdx.y;
	if(row >= total_rows)
		return;

	uint32_t off;
	off = blockIdx.x * TRUNK_SIZE / sizeof(encode_t);
	uint32_t in_off=off*columns;
	encode_t * in =(encode_t *)cuda_in,*out = (encode_t *)cuda_out;

	//Reverse the order to solve shared memory bank conflict.
	__shared__ encode_t mul_result[2][64];
	mul_result[threadIdx.y][threadIdx.x] = 0;
	__syncthreads();
	int bit_index = threadIdx.x>>3;
	int bit_off = threadIdx.x&0x07;
	for(int k=0;k<columns;k++){
		encode_t temp = 0;
		uint8_t mask = bitmatrix[row][bit_index];
		for(int j=0;j<8;j++){
			temp ^= ((mask & (1<<j)) ? mul_result[threadIdx.y][8*j+bit_off] : 0);
		}
		__syncthreads();
		mul_result[threadIdx.y][threadIdx.x] = temp ^ in[in_off +k*64 +threadIdx.x];
		__syncthreads();
	}
	out[size/columns/sizeof(encode_t) * row+off+threadIdx.x] = mul_result[threadIdx.y][threadIdx.x];
}


size_t ec_method_batch_encode(size_t size, uint32_t columns, uint32_t total_rows,
        uint8_t * in, uint8_t ** out)
{

		uint8_t* cuda_in[NUMBER_OF_STREAM],*cuda_out[NUMBER_OF_STREAM];

		long long memory_trunk_size = (1<<18) *columns;

		cudaStream_t streams[NUMBER_OF_STREAM];
		for(int i=0;i<NUMBER_OF_STREAM;i++)
			cudaStreamCreate(&streams[i]);

		int memory_trunk_count = (size+memory_trunk_size-1)/(memory_trunk_size);

		for(int s=0;s<NUMBER_OF_STREAM;s++){
			cudaMalloc(&cuda_in[s],memory_trunk_size);
			cudaMalloc(&cuda_out[s],memory_trunk_size/columns*total_rows);
		}

		for(int round=0;round<(memory_trunk_count+NUMBER_OF_STREAM-1)/NUMBER_OF_STREAM;round++){

				int max_stream = min(NUMBER_OF_STREAM,memory_trunk_count - round*NUMBER_OF_STREAM);

				for(int s=0;s<max_stream;s++){
					int trunk_id = round * NUMBER_OF_STREAM + s;
					long long size_trunk = min(memory_trunk_size,size-trunk_id*memory_trunk_size);

					cudaMemcpyAsync(cuda_in[s],in+trunk_id*memory_trunk_size,size_trunk,cudaMemcpyHostToDevice,streams[s]);
				}
				for(int s=0;s<max_stream;s++){
					int trunk_id = round * NUMBER_OF_STREAM + s;
					long long size_trunk = min(memory_trunk_size,size-trunk_id*memory_trunk_size);

					dim3 threadsPerBlock (64,2);
					dim3 blocksPerGrid (size_trunk /columns / TRUNK_SIZE,((total_rows+1)/2));
					encode_batch_kernel<<<blocksPerGrid,threadsPerBlock,0,streams[s]>>>(columns,total_rows,cuda_in[s],cuda_out[s],size_trunk);
				}
				for(int s=0;s<max_stream;s++){
					int trunk_id = round * NUMBER_OF_STREAM + s;
					long long size_trunk = min(memory_trunk_size,size-trunk_id*memory_trunk_size);

					for(int i=0;i<total_rows;i++)
						cudaMemcpyAsync(out[i]+trunk_id*memory_trunk_size/columns,cuda_out[s]+i*size_trunk/columns,size_trunk/columns,cudaMemcpyDeviceToHost,streams[s]);
				}
		}

		for(int s=0;s<NUMBER_OF_STREAM;s++){
			cudaFree(cuda_in[s]);
			cudaFree(cuda_out[s]);
		}
		return size / columns;
}




__global__ void decode_kernel(uint32_t columns,uint8_t* cuda_in,uint8_t *cuda_out,size_t size)
{
		uint32_t off,inv,value,last,j;
		int trunk_id = blockIdx.x;
		off = trunk_id * TRUNK_SIZE / sizeof(encode_t);
		encode_t * in =(encode_t *)cuda_in,*out = (encode_t *)cuda_out;
		int inv_stride = columns +1;
		int in_stride = size / sizeof(encode_t);
		__shared__ encode_t mul_result[2][64];
		__shared__ uint8_t log[EC_GF_SIZE *2];
		__shared__ uint8_t pow[EC_GF_SIZE *2];


		mul_result[threadIdx.y][threadIdx.x] = 0;
		for(int i=threadIdx.x*8+threadIdx.y*4;i<threadIdx.x*8+threadIdx.y*4+4;i++)
			pow[i] = GfPow_cuda[i],log[i] = GfLog_cuda[i];
		__syncthreads();


		int i = blockIdx.y * blockDim.y + threadIdx.y;
		mul_result[threadIdx.y][threadIdx.x] = 0;
		__syncthreads();
		last = 0;
		j = 0;
		int bit_index = threadIdx.x>>3;
		int bit_off = threadIdx.x&0x07;
		do{
			while(j<columns && inverse[i*inv_stride+j] == 0)
				j++;
			if(j<columns){
				inv = inverse[i*inv_stride+j];
				value = pow[EC_GF_SIZE - 1 + log[last] - log[inv]];
				last = inv;
				encode_t temp = 0;
				if(value!=0){
					uint8_t mask = bitmatrix[value-1][bit_index];
					for(int k=0;k<8;k++){
							temp ^= ((mask & (1<<k)) ? mul_result[threadIdx.y][8*k+bit_off] : 0);
					}
				}
				__syncthreads();
				mul_result[threadIdx.y][threadIdx.x] = temp ^ in[off +j*in_stride +threadIdx.x];
				__syncthreads();
				j++;
			}
		}while(j<columns);

		encode_t temp = 0;
		if(last!=0){
			uint8_t mask = bitmatrix[last-1][bit_index];
			for(int k=0;k<8;k++){
				temp ^= ((mask & (1<<k)) ? mul_result[threadIdx.y][8*k+bit_off] : 0);
			}
		}
		__syncthreads();
		mul_result[threadIdx.y][threadIdx.x] = temp;
		__syncthreads();


		out[off*columns+threadIdx.x+i*TRUNK_SIZE/sizeof(encode_t)] = mul_result[threadIdx.y][threadIdx.x];
		__syncthreads();



}

size_t ec_method_decode(size_t size, uint32_t columns, uint32_t * rows,
                        uint8_t ** in, uint8_t * out)
{
    uint32_t i, j, k;
    uint32_t f;
    uint8_t **inv;
    uint8_t **mtx;
    uint8_t *in_ptr;


    //Use some tricks to allocate 2-d array which is cache-friendly.
    inv = (uint8_t **)malloc(sizeof(uint8_t *) *columns);
    mtx = (uint8_t **)malloc(sizeof(uint8_t *) *columns);


    inv[0] = (uint8_t *)malloc((columns + 1)*columns * sizeof(uint8_t));
    mtx[0] = (uint8_t *)malloc(columns*columns * sizeof(uint8_t ));


    for(i=0;i<columns;i++)
        inv[i] = (*inv + (columns+1) * i),mtx[i]=(*mtx + columns * i);


    for(i=0;i<columns;i++){
        for(j=0;j<columns;j++)
            inv[i][j]=mtx[i][j]=0;
        inv[i][columns] = 0;
    }

    for (i = 0; i < columns; i++)
    {
        inv[i][i] = 1;
        inv[i][columns] = 1;
    }
    for (i = 0; i < columns; i++)
    {
        mtx[i][columns - 1] = 1;
        for (j = columns - 1; j > 0; j--)
        {
            mtx[i][j - 1] = ec_method_mul(mtx[i][j], rows[i] + 1);
        }
    }

    for (i = 0; i < columns; i++)
    {
        f = mtx[i][i];
        for (j = 0; j < columns; j++)
        {
            mtx[i][j] = ec_method_div(mtx[i][j], f);
            inv[i][j] = ec_method_div(inv[i][j], f);
        }
        for (j = 0; j < columns; j++)
        {
            if (i != j)
            {
                f = mtx[j][i];
                for (k = 0; k < columns; k++)
                {
                    mtx[j][k] ^= ec_method_mul(mtx[i][k], f);
                    inv[j][k] ^= ec_method_mul(inv[i][k], f);
                }
            }
        }
    }

    cudaMemcpyToSymbol(inverse,*inv,sizeof(uint8_t) * columns *(columns+1));

    uint8_t* cuda_in[NUMBER_OF_STREAM],*cuda_out[NUMBER_OF_STREAM];

    long long memory_trunk_size = (1<<18) ;

    cudaStream_t streams[NUMBER_OF_STREAM];
    for(int i=0;i<NUMBER_OF_STREAM;i++)
    	cudaStreamCreate(&streams[i]);

    int memory_trunk_count = (size+memory_trunk_size-1)/(memory_trunk_size);

    for(int s=0;s<NUMBER_OF_STREAM;s++){
    	cudaMalloc(&cuda_in[s],memory_trunk_size * columns);
    	cudaMalloc(&cuda_out[s],memory_trunk_size * columns);
    }

    in_ptr = (uint8_t *)malloc(memory_trunk_size * columns *NUMBER_OF_STREAM);

    for(int round=0;round<(memory_trunk_count+NUMBER_OF_STREAM-1)/NUMBER_OF_STREAM;round++){

    		int max_stream = min(NUMBER_OF_STREAM,memory_trunk_count - round*NUMBER_OF_STREAM);

    		for(int s=0;s<max_stream;s++){
    			int trunk_id = round * NUMBER_OF_STREAM + s;
    			long long size_trunk = min(memory_trunk_size,size-trunk_id*memory_trunk_size);

    			for(i=0;i<columns;i++)
    			    	memcpy(in_ptr + s*memory_trunk_size*columns + i*memory_trunk_size,in[i]+trunk_id*memory_trunk_size,size_trunk);
    		}

    		for(int s=0;s<max_stream;s++){
    			int trunk_id = round * NUMBER_OF_STREAM + s;
    			long long size_trunk = min(memory_trunk_size,size-trunk_id*memory_trunk_size);

    			cudaMemcpyAsync(cuda_in[s],in_ptr + s*memory_trunk_size*columns,size_trunk * columns,cudaMemcpyHostToDevice,streams[s]);
    		}
    		for(int s=0;s<max_stream;s++){
    			int trunk_id = round * NUMBER_OF_STREAM + s;
    			long long size_trunk = min(memory_trunk_size,size-trunk_id*memory_trunk_size);

    			dim3 threadsPerBlock (64,2);
    			dim3 blocksPerGrid (size_trunk / TRUNK_SIZE,((columns+1)/2));
    			decode_kernel<<<blocksPerGrid,threadsPerBlock,0,streams[s]>>>(columns,cuda_in[s],cuda_out[s],size_trunk);
    		}
    		for(int s=0;s<max_stream;s++){
    			int trunk_id = round * NUMBER_OF_STREAM + s;
    			long long size_trunk = min(memory_trunk_size,size-trunk_id*memory_trunk_size);

    			cudaMemcpyAsync(out+trunk_id*memory_trunk_size*columns,cuda_out[s],size_trunk*columns,cudaMemcpyDeviceToHost,streams[s]);
    		}
    	}

    	for(int s=0;s<NUMBER_OF_STREAM;s++){
    		cudaFree(cuda_in[s]);
    		cudaFree(cuda_out[s]);
    	}

    free(in_ptr);
    free(inv[0]);
    free(mtx[0]);
    free(inv);
    free(mtx);

    return size * TRUNK_SIZE * columns;
}





