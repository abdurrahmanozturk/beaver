#!/bin/sh
python ~/projects/beaver/scripts/multirun.py point_defectsND.i D/Di 1e-10:1:4x
python ~/projects/beaver/scripts/multirun.py point_defectsND.i D/Dv 1e-10:1:4x
python ~/projects/beaver/scripts/multirun.py point_defectsND.i kiv 1e-4:1e10:4x
python ~/projects/beaver/scripts/multirun.py point_defectsND.i value 1e-4:1:4x
