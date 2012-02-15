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
#ifndef __TUPI_H_
#define __TUPI_H_
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include <graphviz/types.h>
#include <graphviz/graph.h>
#include "Layout.h"
#include "LayoutRunner.h"

@interface Tupi : NSObject
{
  id window;
  id view;
  NSMutableDictionary *graph;
  Layout *layout;
}
- (NSEnumerator *) graphNodesEnumerator;
- (NSEnumerator *) particlesEnumerator;
- (NSRect) boundingBox;
- (void) layoutChanged;
@end
#endif
