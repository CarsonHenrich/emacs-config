# SPDX-FileCopyrightText: 2025 Carson Henrich <carson03henrich@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

{ inputs, cell }: cell.installables.emacs-env.makeApps { lockDirName = ".lock"; }
