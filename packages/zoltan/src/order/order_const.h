/*****************************************************************************
 * Zoltan Dynamic Load-Balancing Library for Parallel Applications           *
 * Copyright (c) 2000, Sandia National Laboratories.                         *
 * For more info, see the README file in the top-level Zoltan directory.     *  
 *****************************************************************************/
/*****************************************************************************
 * CVS File Information :
 *    $RCSfile$
 *    $Author$
 *    $Date$
 *    $Revision$
 ****************************************************************************/

#ifndef __ORDER_CONST_H
#define __ORDER_CONST_H

#include "zoltan.h"

/*
 * Definition of the Zoltan Ordering Struct (ZOS).
 */

struct Zoltan_Order_Struct {
  ZZ *zz;                       /* ptr to Zoltan struct */
  int num_objects;              /* # of objects (local) */
  ZOLTAN_ID_PTR gids;           /* ptr to (ordered) global ids */
  ZOLTAN_ID_PTR lids;           /* ptr to (ordered) local ids */
  char *method;   		/* Ordering method used */
  int  num_separators;          /* Optional: # of separators. */
  int *sep_sizes;               /* Optional: Separator sizes. */
};

/*
 * Type definitions for functions that depend on 
 * ordering method or uses the ordering struct.
 */

typedef int ZOLTAN_ORDER_FN(struct Zoltan_Struct *, 
                         ZOLTAN_ID_PTR *, ZOLTAN_ID_PTR *, 
                         struct Zoltan_Order_Struct *);

typedef struct Zoltan_Order_Struct ZOS;

/*****************************************************************************/
/* PROTOTYPES */

/* ORDERING FUNCTIONS */
extern ZOLTAN_ORDER_FN Zoltan_ParMetis_Order;

/* FREE DATA_STRUCTURE FUNCTIONS */
/* EB: Do we need this for orderings? 
extern ZOLTAN_LB_FREE_DATA_FN Zoltan_RCB_Free_Structure;
*/

#endif
