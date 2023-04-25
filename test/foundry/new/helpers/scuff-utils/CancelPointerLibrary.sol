pragma solidity ^0.8.17;

import "./ScuffDirectives.sol";
import "./DynArrayOrderComponentsPointerLibrary.sol";
import { OrderComponents } from "../../../../../contracts/lib/ConsiderationStructs.sol";
import "../../../../../contracts/helpers/PointerLibraries.sol";

type CancelPointer is uint256;

using Scuff for MemoryPointer;
using CancelPointerLibrary for CancelPointer global;

/// @dev Library for resolving pointers of encoded calldata for
/// cancel(OrderComponents[])
library CancelPointerLibrary {
  enum ScuffKind { orders_HeadOverflow, orders_length_DirtyBits, orders_length_MaxValue, orders_element_HeadOverflow, orders_element_offerer_DirtyBits, orders_element_offerer_MaxValue, orders_element_zone_DirtyBits, orders_element_zone_MaxValue, orders_element_offer_HeadOverflow, orders_element_offer_length_DirtyBits, orders_element_offer_length_MaxValue, orders_element_offer_element_itemType_DirtyBits, orders_element_offer_element_itemType_MaxValue, orders_element_offer_element_token_DirtyBits, orders_element_offer_element_token_MaxValue, orders_element_consideration_HeadOverflow, orders_element_consideration_length_DirtyBits, orders_element_consideration_length_MaxValue, orders_element_consideration_element_itemType_DirtyBits, orders_element_consideration_element_itemType_MaxValue, orders_element_consideration_element_token_DirtyBits, orders_element_consideration_element_token_MaxValue, orders_element_consideration_element_recipient_DirtyBits, orders_element_consideration_element_recipient_MaxValue, orders_element_orderType_DirtyBits, orders_element_orderType_MaxValue }

  enum ScuffableField { orders }

  bytes4 internal constant FunctionSelector = 0xfd9f1e10;
  string internal constant FunctionName = "cancel";
  uint256 internal constant HeadSize = 0x20;
  uint256 internal constant MinimumOrdersScuffKind = uint256(ScuffKind.orders_length_DirtyBits);
  uint256 internal constant MaximumOrdersScuffKind = uint256(ScuffKind.orders_element_orderType_MaxValue);

  /// @dev Convert a `MemoryPointer` to a `CancelPointer`.
  /// This adds `CancelPointerLibrary` functions as members of the pointer
  function wrap(MemoryPointer ptr) internal pure returns (CancelPointer) {
    return CancelPointer.wrap(MemoryPointer.unwrap(ptr.offset(4)));
  }

  /// @dev Convert a `CancelPointer` back into a `MemoryPointer`.
  function unwrap(CancelPointer ptr) internal pure returns (MemoryPointer) {
    return MemoryPointer.wrap(CancelPointer.unwrap(ptr));
  }

  function isFunction(bytes4 selector) internal pure returns (bool) {
    return FunctionSelector == selector;
  }

  /// @dev Convert a `bytes` with encoded calldata for `cancel`to a `CancelPointer`.
  /// This adds `CancelPointerLibrary` functions as members of the pointer
  function fromBytes(bytes memory data) internal pure returns (CancelPointer ptrOut) {
    assembly {
      ptrOut := add(data, 0x24)
    }
  }

  /// @dev Encode function call from arguments
  function fromArgs(OrderComponents[] memory orders) internal pure returns (CancelPointer ptrOut) {
    bytes memory data = abi.encodeWithSignature("cancel((address,address,(uint8,address,uint256,uint256,uint256)[],(uint8,address,uint256,uint256,uint256,address)[],uint8,uint256,uint256,bytes32,uint256,bytes32,uint256)[])", orders);
    ptrOut = fromBytes(data);
  }

  /// @dev Resolve the pointer to the head of `orders` in memory.
  /// This points to the offset of the item's data relative to `ptr`
  function ordersHead(CancelPointer ptr) internal pure returns (MemoryPointer) {
    return ptr.unwrap();
  }

  /// @dev Resolve the `DynArrayOrderComponentsPointer` pointing to the data buffer of `orders`
  function ordersData(CancelPointer ptr) internal pure returns (DynArrayOrderComponentsPointer) {
    return DynArrayOrderComponentsPointerLibrary.wrap(ptr.unwrap().offset(ordersHead(ptr).readUint256()));
  }

  /// @dev Resolve the pointer to the tail segment of the encoded calldata.
  /// This is the beginning of the dynamically encoded data.
  function tail(CancelPointer ptr) internal pure returns (MemoryPointer) {
    return ptr.unwrap().offset(HeadSize);
  }

  function addScuffDirectives(CancelPointer ptr, ScuffDirectivesArray directives, uint256 kindOffset, ScuffPositions positions) internal pure {
    /// @dev Overflow offset for `orders`
    directives.push(Scuff.lower(uint256(ScuffKind.orders_HeadOverflow) + kindOffset, 224, ptr.ordersHead(), positions));
    /// @dev Add all nested directives in orders
    ptr.ordersData().addScuffDirectives(directives, kindOffset + MinimumOrdersScuffKind, positions);
  }

  function getScuffDirectives(CancelPointer ptr) internal pure returns (ScuffDirective[] memory) {
    ScuffDirectivesArray directives = Scuff.makeUnallocatedArray();
    ScuffPositions positions = EmptyPositions;
    addScuffDirectives(ptr, directives, 0, positions);
    return directives.finalize();
  }

  function getScuffDirectivesForCalldata(bytes memory data) internal pure returns (ScuffDirective[] memory) {
    return getScuffDirectives(fromBytes(data));
  }

  function toString(ScuffKind k) internal pure returns (string memory) {
    if (k == ScuffKind.orders_HeadOverflow) return "orders_HeadOverflow";
    if (k == ScuffKind.orders_length_DirtyBits) return "orders_length_DirtyBits";
    if (k == ScuffKind.orders_length_MaxValue) return "orders_length_MaxValue";
    if (k == ScuffKind.orders_element_HeadOverflow) return "orders_element_HeadOverflow";
    if (k == ScuffKind.orders_element_offerer_DirtyBits) return "orders_element_offerer_DirtyBits";
    if (k == ScuffKind.orders_element_offerer_MaxValue) return "orders_element_offerer_MaxValue";
    if (k == ScuffKind.orders_element_zone_DirtyBits) return "orders_element_zone_DirtyBits";
    if (k == ScuffKind.orders_element_zone_MaxValue) return "orders_element_zone_MaxValue";
    if (k == ScuffKind.orders_element_offer_HeadOverflow) return "orders_element_offer_HeadOverflow";
    if (k == ScuffKind.orders_element_offer_length_DirtyBits) return "orders_element_offer_length_DirtyBits";
    if (k == ScuffKind.orders_element_offer_length_MaxValue) return "orders_element_offer_length_MaxValue";
    if (k == ScuffKind.orders_element_offer_element_itemType_DirtyBits) return "orders_element_offer_element_itemType_DirtyBits";
    if (k == ScuffKind.orders_element_offer_element_itemType_MaxValue) return "orders_element_offer_element_itemType_MaxValue";
    if (k == ScuffKind.orders_element_offer_element_token_DirtyBits) return "orders_element_offer_element_token_DirtyBits";
    if (k == ScuffKind.orders_element_offer_element_token_MaxValue) return "orders_element_offer_element_token_MaxValue";
    if (k == ScuffKind.orders_element_consideration_HeadOverflow) return "orders_element_consideration_HeadOverflow";
    if (k == ScuffKind.orders_element_consideration_length_DirtyBits) return "orders_element_consideration_length_DirtyBits";
    if (k == ScuffKind.orders_element_consideration_length_MaxValue) return "orders_element_consideration_length_MaxValue";
    if (k == ScuffKind.orders_element_consideration_element_itemType_DirtyBits) return "orders_element_consideration_element_itemType_DirtyBits";
    if (k == ScuffKind.orders_element_consideration_element_itemType_MaxValue) return "orders_element_consideration_element_itemType_MaxValue";
    if (k == ScuffKind.orders_element_consideration_element_token_DirtyBits) return "orders_element_consideration_element_token_DirtyBits";
    if (k == ScuffKind.orders_element_consideration_element_token_MaxValue) return "orders_element_consideration_element_token_MaxValue";
    if (k == ScuffKind.orders_element_consideration_element_recipient_DirtyBits) return "orders_element_consideration_element_recipient_DirtyBits";
    if (k == ScuffKind.orders_element_consideration_element_recipient_MaxValue) return "orders_element_consideration_element_recipient_MaxValue";
    if (k == ScuffKind.orders_element_orderType_DirtyBits) return "orders_element_orderType_DirtyBits";
    return "orders_element_orderType_MaxValue";
  }

  function toKind(uint256 k) internal pure returns (ScuffKind) {
    return ScuffKind(k);
  }

  function toKindString(uint256 k) internal pure returns (string memory) {
    return toString(toKind(k));
  }
}