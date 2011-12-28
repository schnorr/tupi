/*
    This file is part of ForceDirected

    ForceDirected is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ForceDirected is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with ForceDirected.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef __LAYOUT_H__
#define __LAYOUT_H__
#include <Foundation/Foundation.h>
#include "Cell.h"
#include "ParticleBox.h"
#include "QuadTreeCellSpace.h"
#include "BarycenterCellData.h"
#include "Energy.h"

@protocol LayoutProtocol 
- (long) numberOfMovedNodes;
- (double) stabilization;
- (double) stabilizationLimit;
- (NSTimeInterval) lastStepDuration;
- (int) quality;
- (void) setQuality: (int) q;
- (double) force;
- (void) setForce: (double) f; //[0..1]

- (void) moveNode: (NSString*) id toLocation: (NSPoint) newLocation;
- (void) freezeNode: (NSString*) id to: (BOOL) frozen;

- (void) shake;
- (void) clear;
- (void) compute;
@end

@class ParticleBox;
@class Cell;

@interface Layout : NSObject <LayoutProtocol> 
{
  id provider;

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
  double lastStepDuration;
  NSRect area;
  double diagonalOfArea; // the diagonal of the graph area at the current step.
  double maxMoveLength; // The maximum length of a node displacement at the current step.
  double averageLength; // Average move length.
  long numberOfMovedNodes;

  //settings
  double stabilizationLimit; // stabilisation limit of this algorithm.
}
- (void) setProvider: (id) prov;
- (NSArray *)allParticles;
- (NSRect) boundingBox;
- (Cell *)rootCell;
- (Energy*) energy;

// Graph representation
- (void) addNode: (id) node withName: (NSString *) nodeName;

@end

#endif