!!ARBfp1.0
TEMP tempColor, negColor;
TEX tempColor, fragment.texcoord[0], texture[0], RECT;
RCP negColor.a, tempColor.a;
MAD tempColor.rgb, -negColor.a, tempColor, 1.0;
MUL tempColor.rgb, tempColor.a, tempColor;
MUL tempColor, fragment.color, tempColor;
SUB tempColor.gb, tempColor, tempColor;
# here is where we will dim.
MUL tempColor.a, .6, tempColor.a;
MUL tempColor.r, 0.6, tempColor.r;
MOV result.color, tempColor;
END
