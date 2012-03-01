/*
    This file is part of Tupi

    Tupi is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Tupi is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Tupi.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef __LAYOUT_H__
#define __LAYOUT_H__
#include <Foundation/Foundation.h>
#include "Cell.h"
#include "ParticleBox.h"
#include "QuadTreeCellSpace.h"
#include "BarycenterCellData.h"
#include "Energy.h"
#include "TupiProtocols.h"

@protocol LayoutProtocol 
- (long) numberOfMovedNodes;
- (double) stabilization;
- (double) stabilizationLimit;
- (int) quality;
- (void) setQuality: (int) q;
- (double) force;
- (void) setForce: (double) f; //[0..1]

- (void) freezeNode: (id<FDNode>) node frozen: (BOOL) fr;
- (void) removeNode: (id<FDNode>) node;
- (void) addNode: (id<FDNode>) node withName: (NSString *) nodeName;
- (void) addNode: (id<FDNode>) node withName: (NSString *) nodeName withLocation: (NSPoint) loc;
- (void) moveNode: (id<FDNode>) node toLocation: (NSPoint) loc;


- (void) shake;
- (void) clear;
- (void) compute;
@end

@class ParticleBox;
@class Cell;

@interface Layout : NSObject <LayoutProtocol> 
{
  ParticleBox *mainBox;
  Energy *energy;

  @public
  //parameters
  double k; // optimal distance between nodes.
  double K1; // default attraction.
  double K2; // default repulsion.
  double force; // global force strength in [0..1] that is used to scale moves
  double viewZone; // view distance at which the cells of the n-tree are explored exhaustively, after this the poles are used. This is a multiple of k.
  double theta; //Barnes/Hut theta threshold to know if we use a pole or not.
  int quality; // quality level.
  int nodesPerCell; // number of nodes per space-cell.

  //statistics
  int time; // Current step.
  NSRect area;
  double diagonalOfArea; // the diagonal of the graph area at the current step.
  double maxMoveLength; // The maximum length of a node displacement at the current step.
  double averageLength; // Average move length.
  long numberOfMovedNodes;

  //settings
  double stabilizationLimit; // stabilisation limit of this algorithm.

  NSConditionLock *lock;
}
- (NSArray *)allParticles;
- (NSRect) boundingBox;
- (Cell *)rootCell;
- (Energy*) energy;
@end

#endif
