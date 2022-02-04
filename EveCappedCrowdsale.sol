pragma solidity ^0.4.23;

import "./SafeMath.sol";
// import "../Crowdsale.sol";
import "./Ownable.sol";
import "./PostDeliveryCrowdsale.sol";
import "./TimedCrowdsale.sol";


/**
 * @title EveCappedCrowdsale
 * @dev Crowdsale with per-user caps.
 */
contract EveCappedCrowdsale is Ownable, PostDeliveryCrowdsale, TimedCrodsale {
  using SafeMath for uint256;



  mapping(address => uint256) public contributions;
  // mapping(address => uint256) public caps;
  uint256 public individualCap;
  bool public individualCapsOn = true;

  constructor(uint256 _individualCap, uint256 _openingTime, uint256 _closingTime) PostDeliveryCrowdsale(_openingTime, _closingTime) public {
    _individualCap = individualCap;
  } 

  /**
   * @dev Returns the amount contributed so far by a sepecific user.
   * @param _beneficiary Address of contributor
   * @return User contribution so far
   */
  function getUserContribution(address _beneficiary)
    public view returns (uint256)
  {
    return contributions[_beneficiary];
  }

   /**
   * @dev Toggle individual caps for purchases.
   * @param _individualCapsOn TRUE for setting individual caps on. False for setting individual caps off.
   */
  function setIndividualCaps(bool _individualCapsOn) external onlyOwner{
    individualCapsOn = _individualCapsOn;
  }

  /**
   * @dev Modify individual cap value.
   * @param _individualCap Amount set as cap.
   */
  function changeIndividualCap(uint256 _individualCap) external onlyOwner{
    individualCap = _individualCap;
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the user's funding cap.
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(!individualCap || contributions[_beneficiary].add(_weiAmount) <= individualCap);
  }

  /**
   * @dev Extend parent behavior to update user contributions
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    super._updatePurchasingState(_beneficiary, _weiAmount);
    contributions[_beneficiary] = contributions[_beneficiary].add(_weiAmount);
  }

}
