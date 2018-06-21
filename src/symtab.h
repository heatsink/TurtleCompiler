#ifndef SYMTAB_H
#define SYMTAB_H 

typedef struct node {
  /* required */
  struct node *next;
  char *name;
  int level;
  /* may be other stuff */
  int defined;

}  node;

extern node *insert(char *s);
extern node *lookup(char *s);
extern node *delete(char *s);
extern void scope_open(void);
extern void scope_close(void);
extern int level;
#endif
