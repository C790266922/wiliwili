pragma solidity ^0.4.20;

interface tokenRecipient {
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

contract owned {
	address public owner;
	
	constructor() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) onlyOwner public {
		owner = newOwner;
	}
}

contract ERC20 {
	string public name;
	string public symbol;
	uint8 public decimals = 18;

	uint256 public totalSupply;

	// array
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;

	// public event
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

	event Burn(address indexed from, uint256 value);

	// constructor
	constructor(uint256 initialSupply, string tokenName, string tokenSymbol) public {
		totalSupply = initialSupply * 10 ** uint256(decimals);
		// totalSupply = initialSupply;
		balanceOf[msg.sender] = totalSupply;
		name = tokenName;
		symbol = tokenSymbol;
	}

	// get balance of given address
	function balanceOf(address _address) public view returns (uint256) {
		return balanceOf[_address];
	}

	function name() public view returns (string) {
		return name;
	}

	function symbol() public view returns (string) {
		return symbol;
	}

	function decimals() public view returns (uint8) {
		return decimals;
	}

	function totalSupply() public view returns (uint) {
		return totalSupply;
	}

	// internal transfer
	function _transfer(address _from, address _to, uint _value) internal {
		require(_to != 0x0);
		require(balanceOf[_from] >= _value);
		// check for overflow
		require(balanceOf[_to] + _value > balanceOf[_to]);

		uint previousBalances = balanceOf[_from] + balanceOf[_to];
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;

		emit Transfer(_from, _to, _value);
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}

	// transfer from msg.sender
	function transfer(address _to, uint256 _value) public returns (bool success) {
		_transfer(msg.sender, _to, _value);
		return true;
	}

	// transfer from other address
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(_value <= allowance[_from][msg.sender]); // check allowance
		allowance[_from][msg.sender] -= _value;
		_transfer(_from, _to, _value);
		return true;
	}

	// set allowance for other address
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	// set allowance for other address and notify
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		if(approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;
		}
	}

	// get allowance
	function allowance(address _owner, address _spender) public view returns (uint remaining) {
		return allowance[_owner][_spender];
	}

	// destory tokens
	function burn(uint256 _value) public returns (bool success) {
		require(balanceOf[msg.sender] >= _value);
		balanceOf[msg.sender] -= _value;
		totalSupply -= _value;
		emit Burn(msg.sender, _value);
		return true;
	}

	// destory tokens from other account
	function burnFrom(address _from, uint256 _value) public returns (bool success) {
		require(balanceOf[_from] >= _value);
		require(_value < allowance[_from][msg.sender]);
		balanceOf[_from] -= _value;
		allowance[_from][msg.sender] -= _value;
		totalSupply -= _value;
		
		emit Burn(_from, _value);
		return true;
	}
}

contract WILI is owned, ERC20 {
	uint256 public sellPrice;
	uint256 public buyPrice;

	mapping (address => bool) public frozenAccount;
	
	event FrozenFunds(address target, bool frozen);

	constructor(uint256 initialSupply, string tokenName, string tokenSymbol) ERC20(initialSupply, tokenName, tokenSymbol) public {}

	function _transfer(address _from, address _to, uint _value) internal {
		require(_to != 0x0);
		require(balanceOf[_from] >= _value);
		require(balanceOf[_to] + _value >= balanceOf[_to]);
		require(!frozenAccount[_from]);
		require(!frozenAccount[_to]);

		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;
		
		emit Transfer(_from, _to, _value);
	}

	function mintToken(address target, uint256 mintedAmount) onlyOwner public {
		balanceOf[target] += mintedAmount;
		totalSupply += mintedAmount;
		emit Transfer(0, this, mintedAmount);
		emit Transfer(this, target, mintedAmount);
	}

	function freezeAccount(address target, bool freeze) onlyOwner public {
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
	}

	function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
		sellPrice = newSellPrice;
		buyPrice = newBuyPrice;
	}

	function buy() payable public {
		uint amount = msg.value / buyPrice;
		_transfer(this, msg.sender, amount);
	}

	function sell(uint256 amount) public {
		address myAddress = this;
		require(myAddress.balance >= amount * sellPrice);
		_transfer(msg.sender, this, amount);
		msg.sender.transfer(amount * sellPrice);
	}
}
