/*
    This file is part of Tupi.

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
#ifndef __FDVIEW__H__
#define __FDVIEW__H__
#include <AppKit/AppKit.h>
#include <Renaissance/Renaissance.h>
#include "BasicView.h"
#include "Tupi.h"
#include "GraphNode.h"
#include "Layout.h"

@interface FDView : BasicView
{
  Tupi *provider;
  Layout *layout;
  GraphNode *highlighted;
}
- (void) setProvider: (Tupi *) p;
- (void) setLayout: (Layout *) l;
@end

#endif
