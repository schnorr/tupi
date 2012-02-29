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
#ifndef __TUPIPROTOCOLS_H__
#define __TUPIPROTOCOLS_H__

@protocol FDNode <NSObject>
@required
- (NSPoint) position;
- (void) setPosition: (NSPoint) newPosition;
- (NSSet *) connectedNodes;
- (BOOL) isConnectedTo: (id<FDNode>) n;
- (void) setParticle: (id)p;
- (id) particle;
@optional
- (void) addConnectedNode: (id<FDNode>) n;
- (void) removeConnectedNode: (id<FDNode>) n;
- (void) removeFromAllConnectedNodes;
- (void) setName: (NSString*) newName;
- (NSString *) name;
@end

@protocol TupiNode <FDNode>
@end

@protocol TupiProvider <NSObject>
- (void) layoutChanged;
@end

#endif
