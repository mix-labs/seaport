// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {
    ConsiderationInterface
} from "seaport-types/src/interfaces/ConsiderationInterface.sol";
import {
    AdvancedOrder,
    CriteriaResolver
} from "seaport-types/src/lib/ConsiderationStructs.sol";

import {
    SeaportValidatorInterface
} from "../order-validator/SeaportValidator.sol";

import { OrderHelperContextLib } from "./lib/OrderHelperLib.sol";

import { CriteriaHelperLib } from "./lib/CriteriaHelperLib.sol";

import {
    CriteriaConstraint,
    OrderHelperContext,
    OrderHelperRequest,
    OrderHelperResponse
} from "./lib/SeaportOrderHelperTypes.sol";

import {
    SeaportOrderHelperInterface
} from "./lib/SeaportOrderHelperInterface.sol";

import { HelperInterface } from "./lib/HelperInterface.sol";
import { RequestValidator } from "./lib/RequestValidator.sol";
import { CriteriaResolverHelper } from "./lib/CriteriaResolverHelper.sol";
import { SeaportValidatorHelper } from "./lib/SeaportValidatorHelper.sol";
import { OrderDetailsHelper } from "./lib/OrderDetailsHelper.sol";
import { FulfillmentsHelper } from "./lib/FulfillmentsHelper.sol";
import { ExecutionsHelper } from "./lib/ExecutionsHelper.sol";

/**
 * @notice SeaportOrderHelper is a helper contract that generates additional
 *         information useful for fulfilling Seaport orders. Given an array of
 *         orders and external parameters like caller, recipient, and native
 *         tokens supplied, SeaportOrderHelper will validate the orders and
 *         return associated errors and warnings, recommend a fulfillment
 *         method, suggest fulfillments, provide execution and order details,
 *         and optionally generate criteria resolvers from provided token IDs.
 */
contract SeaportOrderHelper is SeaportOrderHelperInterface {
    using OrderHelperContextLib for OrderHelperContext;
    using CriteriaHelperLib for uint256[];

    ConsiderationInterface public immutable seaport;
    SeaportValidatorInterface public immutable validator;

    RequestValidator public immutable requestValidator;
    CriteriaResolverHelper public immutable criteriaResolverHelper;
    SeaportValidatorHelper public immutable seaportValidatorHelper;
    OrderDetailsHelper public immutable orderDetailsHelper;
    FulfillmentsHelper public immutable fulfillmentsHelper;
    ExecutionsHelper public immutable executionsHelper;

    HelperInterface[] public helpers;

    constructor(
        ConsiderationInterface _seaport,
        SeaportValidatorInterface _validator
    ) {
        seaport = _seaport;
        validator = _validator;

        requestValidator = new RequestValidator();
        criteriaResolverHelper = new CriteriaResolverHelper();
        seaportValidatorHelper = new SeaportValidatorHelper();
        orderDetailsHelper = new OrderDetailsHelper();
        fulfillmentsHelper = new FulfillmentsHelper();
        executionsHelper = new ExecutionsHelper();

        helpers.push(requestValidator);
        helpers.push(criteriaResolverHelper);
        helpers.push(seaportValidatorHelper);
        helpers.push(orderDetailsHelper);
        helpers.push(fulfillmentsHelper);
        helpers.push(executionsHelper);
    }

    function prepare(
        OrderHelperRequest memory request
    ) public view returns (OrderHelperResponse memory) {
        OrderHelperContext memory context = OrderHelperContextLib.from(
            seaport,
            validator,
            request
        );

        for (uint256 i; i < helpers.length; i++) {
            context = helpers[i].prepare(context);
        }

        return context.response;
    }

    /**
     * @notice Generate a criteria merkle root from an array of `tokenIds`. Use
     *         this helper to construct an order item's `identifierOrCriteria`.
     *
     * @param tokenIds An array of integer token IDs to be converted to a merkle
     *                 root.
     *
     * @return The bytes32 merkle root of a criteria tree containing the given
     *         token IDs.
     */
    function criteriaRoot(
        uint256[] memory tokenIds
    ) external pure returns (bytes32) {
        return tokenIds.criteriaRoot();
    }

    /**
     * @notice Generate a criteria merkle proof that `id` is a member of
     *        `tokenIds`. Reverts if `id` is not a member of `tokenIds`. Use
     *         this helper to construct proof data for criteria resolvers.
     *
     * @param tokenIds An array of integer token IDs.
     * @param id       The integer token ID to generate a proof for.
     *
     * @return Merkle proof that the given token ID is  amember of the criteria
     *         tree containing the given token IDs.
     */
    function criteriaProof(
        uint256[] memory tokenIds,
        uint256 id
    ) external pure returns (bytes32[] memory) {
        return tokenIds.criteriaProof(id);
    }
}