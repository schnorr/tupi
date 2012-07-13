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
#include <Renaissance/Renaissance.h>
#include <Foundation/Foundation.h>
#include <Renaissance/Renaissance.h>
#include <AppKit/AppKit.h>
#include <sys/time.h>
#include <graphviz/types.h>
#include <graphviz/graph.h>
#include "Tupi.h"

double gettime ()
{
  struct timeval tr;
  gettimeofday(&tr, NULL);
  return (double)tr.tv_sec+(double)tr.tv_usec/1000000;
}

int main (int argc, const char **argv)
{
  aginit();
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSApplication *app = [NSApplication sharedApplication];
  Tupi *delegate = [Tupi new];
  [app setDelegate: delegate];

  RELEASE(pool);
  return NSApplicationMain (argc, argv);
}

