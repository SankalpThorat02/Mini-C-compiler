#ifndef TARGETCODE_H
#define TARGETCODE_H

void generateDataSection();
void generateTextSection();
void generateExprRISCV(ASTNode* node);
void generateStmtRISCV(ASTNode* node);
void generateExit();

#endif