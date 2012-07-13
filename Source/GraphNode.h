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
#ifndef __GRAPHNODE_H__
#define __GRAPHNODE_H__
#include <Foundation/Foundation.h>
#include <Renaissance/Renaissance.h>
#include "Particle.h"
#include "TupiProtocols.h"

@class Particle;

@interface GraphNode : NSObject <FDNode>
{
  BOOL high;
  NSRect bb;
  NSPoint pos;
  NSMutableSet *connected;
  NSString *name;
  Particle *particle; //the corresponding particle in the repulsion/att system
}
- (void) setHighlighted: (BOOL) h;
- (BOOL) highlighted;
- (NSRect) boundingBox;
- (void) setBoundingBox: (NSRect) r;
- (void) setParticle: (Particle*)p;
- (Particle*) particle;
@end


#endif
