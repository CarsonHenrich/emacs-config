# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

{
  evil-easymotion = _: prev: {
    packageRequires = {
      evil = "0";
    } // prev.packageRequires;
  };
}
