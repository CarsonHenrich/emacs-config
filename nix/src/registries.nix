# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

{ inputs, emacsSrc }:
[
  {
    name = "local";
    type = "melpa";
    path = ./recipes;
  }

  {
    name = "gnu";
    type = "elpa";
    path = inputs.gnu-elpa.outPath + "/elpa-packages";
    core-src = emacsSrc;
    auto-sync-only = true;
  }

  {
    name = "melpa";
    type = "melpa";
    path = inputs.melpa.outPath + "/recipes";
  }

  {
    name = "nongnu";
    type = "elpa";
    path = inputs.nongnu-elpa.outPath + "/elpa-packages";
  }

  {
    name = "gnu-archive";
    type = "archive";
    url = "https://elpa.gnu.org/packages/";
  }
]
