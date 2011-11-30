#ifndef _ZOLTAN2_ALGRANDOM_HPP_
#define _ZOLTAN2_ALGRANDOM_HPP_

#include <Zoltan2_Standards.hpp>

#include <Zoltan2_GraphModel.hpp>
#include <Zoltan2_OrderingSolution.hpp>


////////////////////////////////////////////////////////////////////////
//! \file Zoltan2_AlgRandom.hpp
//! \brief Random ordering using the Knuth shuffle.
//! \brief TODO: For now uses GraphModel but only needs IDs.


// Placeholder for real error handling.
#define KDD_HANDLE_ERROR {\
    cout << __func__ << ":" << __LINE__ << " KDDERROR" << endl;\
    }

namespace Zoltan2{

template <typename Adapter>
int AlgRandom(
  const RCP<GraphModel<Adapter> > &model, 
  const RCP<OrderingSolution<Adapter> > &solution,
  const RCP<Teuchos::ParameterList> &pl,
  const RCP<const Teuchos::Comm<int> > &comm
) 
{
  typedef typename Adapter::lno_t lno_t;
  typedef typename Adapter::gno_t gno_t;
  typedef typename Adapter::gid_t gid_t;
  typedef typename Adapter::lid_t lid_t;
  typedef typename Adapter::scalar_t scalar_t;

  int ierr= 0;

  HELLO;

  // This is the classic Knuth shuffle, also known as Fisher-Yates shuffle.
  // References:
  //   D.E. Knuth, "The Art of Computer Programming", volume 2, 1969.
  //   R. Durstenfeld, "Algorithm 235: Random permutation", CACM, vol. 7, 1964.

  // Start with the identity permutation.
  const size_t nVtx = model->getLocalNumVertices();
  lno_t *perm;
  perm = new lno_t[nVtx];
  for (lno_t i=0; i<nVtx; i++){
    perm[i] = i;
  }

  // Swap random pairs of indices in perm.
  lno_t j, temp;
  for (lno_t i=nVtx-1; i>0; i--){
    // Choose j randomly in [0,i]
    j = rand() % (i+1);
    // Swap (perm[i], perm[j])
    temp = perm[i];
    perm[i] = perm[j];
    perm[j] = temp;
  }

  // Set solution.
  solution->setPermutation(nVtx,
               (gid_t *) NULL, // TODO
               (lid_t *) NULL, // TODO
               perm);

  // delete [] perm; // Can't delete perm yet, RCP would help here?

  return ierr;
}

}
#endif
