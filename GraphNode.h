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
#ifndef __GRAPHNODE_H__
#define __GRAPHNODE_H__
#include <Foundation/Foundation.h>

@interface GraphNode : NSObject
{
  NSPoint pos;
  NSMutableSet *connected;
  NSString *name;
}
- (NSPoint) position;
- (void) setPosition: (NSPoint) newPosition;
- (NSSet *) connectedNodes;
- (void) addConnectedNode: (GraphNode*) n;
- (BOOL) isConnectedTo: (GraphNode *) n;
- (void) setName: (NSString*) newName;
@end


#endif
