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
#ifndef __NSPointFunctions_H_
#define __NSPointFunctions_H_

#include <math.h>
#include <float.h>

static inline NSPoint NSAddPoints(NSPoint firstPoint, NSPoint secondPoint)
{
        return NSMakePoint(firstPoint.x+secondPoint.x, firstPoint.y+secondPoint.y);
}

static inline NSPoint NSSubtractPoints(NSPoint firstPoint, NSPoint secondPoint)
{
        return NSMakePoint(firstPoint.x-secondPoint.x, firstPoint.y-secondPoint.y);
}

static inline NSPoint NSOffsetPoint(NSPoint point, float amountX, float amountY)
{
    return NSAddPoints(point, NSMakePoint(amountX, amountY));
}

static inline NSPoint NSReflectedPointAboutXAxis(NSPoint point)
{
    return NSMakePoint(-point.x, point.y);
}

static inline NSPoint NSReflectedPointAboutYAxis(NSPoint point)
{
    return NSMakePoint(point.x, -point.y);
}

static inline NSPoint NSReflectedPointAboutOrigin(NSPoint point)
{
    return NSMakePoint(-point.x, -point.y);
}

static inline NSPoint NSTransformedPoint(NSPoint point,NSAffineTransform *transform)
{
        return [transform transformPoint:point];
}

static inline NSPoint NSCartesianToPolar(NSPoint cartesianPoint)
{
    return NSMakePoint(sqrtf(cartesianPoint.x*cartesianPoint.x+cartesianPoint.y*cartesianPoint.y), atan2f(cartesianPoint.y,cartesianPoint.x));
}

static inline NSPoint NSPolarToCartesian(NSPoint polarPoint)
{
    return NSMakePoint(polarPoint.x*cosf(polarPoint.y), polarPoint.x*sinf(polarPoint.y));
}

static inline double LMSAngleBetweenPoints (NSPoint pt1, NSPoint pt2)
{
        double ptxd = pt1.x - pt2.x;
        double ptyd = pt1.y - pt2.y;
        return 90-(atan2 (ptxd, ptyd)/M_PI*180);
}

static inline double LMSDistanceBetweenPoints(NSPoint pt1, NSPoint pt2)
{
        double ptxd = pt1.x - pt2.x;
        double ptyd = pt1.y - pt2.y;
        return sqrt( ptxd*ptxd + ptyd*ptyd );
}

static inline double LMSLengthPoint (NSPoint p)
{
  return sqrt (pow(p.x, 2) +
               pow(p.y, 2));
}

static inline NSPoint LMSNormalizePoint (NSPoint p)
{
  double len = LMSLengthPoint (p);
  if (len != 0) {
    return NSMakePoint (p.x/len,
                        p.y/len);
  }else{
    return NSZeroPoint;
  }
}

static inline NSPoint LMSMultiplyPoint (NSPoint p, double val)
{
        return NSMakePoint (p.x * val, p.y *val);
}

static inline double LMSDiagonalRect (NSRect area)
{
  return LMSDistanceBetweenPoints (area.origin,
                                   NSMakePoint(area.origin.x + area.size.width,
                                               area.origin.y + area.size.height));
}

static inline NSRect LMSGrowCenterPoint (NSPoint p, double val)
{
  return NSMakeRect (p.x-val, p.y-val, 2*val, 2*val);
}

#endif
