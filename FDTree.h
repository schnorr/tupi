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
#ifndef __FDTREE_H_
#define __FDTREE_H_
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "NSPointFunctions.h"

@interface FDTree : NSObject
{
  NSRect mycell;
  FDTree *parent;
  NSMutableArray *children; //of FDTree objects
  NSPoint particle;
  NSPoint pseudoParticle;
  double pseudoParticleCharge;
}
- (id) initWithCell: (NSRect)c
             parent: (FDTree*)p;
- (void) addParticle: (NSPoint)p;
- (NSRect) cell;
- (void) printWithDepth: (int)level;
- (BOOL) isEmpty;
- (void) clean;
- (NSPoint) coulombRepulsionOfParticle:(NSPoint)p
                                charge:(double)charge
                              accuracy:(double)accuracy;
- (void) drawCellsWithLevel:(int)level;
@end
#endif
