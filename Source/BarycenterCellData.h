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
#ifndef __BARYCENTERCELLDATA_H__
#define __BARYCENTERCELLDATA_H__
#include <Foundation/Foundation.h>

@class Cell;

@interface BarycenterCellData : NSObject
{
  NSPoint center;
  double weight;
  Cell *cell;
}
- (NSPoint) center;
- (double) weight;
- (Cell *) cell;
- (double) distanceFromPosition: (NSPoint)pos;
- (void) recompute;
- (void) setCell: (Cell *) c;
- (BarycenterCellData*) newCellData;
@end

#include "Cell.h"
#endif
