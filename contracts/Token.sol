pragma solidity >=0.4.22 <0.6.0;

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a, "");
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a, "");
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "");
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0, "");
        c = a / b;
    }
}

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner, "");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Token is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) _balances;
    mapping(address => mapping(address => uint)) _allowed;

    constructor() public {
        symbol = "JT";
        name = "JToken";
        decimals = 18;
        _totalSupply = 100000000000000000000000000;
        _balances[0xeb341aB27F9082A0091bfd6d1f5DDB9634E288d6] = _totalSupply;
        emit Transfer(address(0), 0xeb341aB27F9082A0091bfd6d1f5DDB9634E288d6, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply - _balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return _balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        _balances[msg.sender] = safeSub(_balances[msg.sender], tokens);
        _balances[to] = safeAdd(_balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        _allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        _balances[from] = safeSub(_balances[from], tokens);
        _allowed[from][msg.sender] = safeSub(_allowed[from][msg.sender], tokens);
        _balances[to] = safeAdd(_balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return _allowed[tokenOwner][spender];
    }

    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        _allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0), "");

        _totalSupply = safeAdd(_totalSupply, value);
        _balances[account] = safeAdd(_balances[account], value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "");
        require(value <= _balances[account], "");

        _totalSupply = safeSub(_totalSupply, value);
        _balances[account] = safeSub(_balances[account], value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {
        require(value <= _allowed[account][msg.sender], "");
        
        _allowed[account][msg.sender] = safeSub(_allowed[account][msg.sender], value);
        _burn(account, value);
    }

    function () external payable {
        revert("");
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}