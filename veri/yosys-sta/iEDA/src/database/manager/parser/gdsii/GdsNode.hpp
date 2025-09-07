// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
//
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
//
// See the Mulan PSL v2 for more details.
// ***************************************************************************************
#pragma once

#include "GdsElement.hpp"

namespace idb {

class GdsNode : public GdsElemBase
{
 public:
  GdsNode() : GdsElemBase(GdsElemType::kNode), layer(0), node_type(0) {}

  GdsNode& operator=(const GdsNode& rhs)
  {
    GdsElemBase::operator=(rhs);
    layer = rhs.layer;
    node_type = rhs.node_type;

    return *this;
  }

  void reset() override
  {
    reset_base();
    layer = 0;
    node_type = 0;
  }

  // members
  GdsLayer layer;
  GdsNodeType node_type;
};

}  // namespace idb
