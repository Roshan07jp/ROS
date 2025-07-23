import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class BlockchainDevScreen extends ConsumerStatefulWidget {
  const BlockchainDevScreen({super.key});

  @override
  ConsumerState<BlockchainDevScreen> createState() => _BlockchainDevScreenState();
}

class _BlockchainDevScreenState extends ConsumerState<BlockchainDevScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _contractController = TextEditingController();
  String _selectedNetwork = 'Ethereum';
  String _selectedLanguage = 'Solidity';
  String _compilationResult = '';

  final List<String> _networks = [
    'Ethereum',
    'Binance Smart Chain',
    'Polygon',
    'Avalanche',
    'Fantom',
    'Arbitrum',
    'Optimism',
    'Solana',
  ];

  final List<String> _languages = [
    'Solidity',
    'Vyper',
    'Rust',
    'JavaScript',
    'TypeScript',
    'Python',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _contractController.text = _getSampleContract();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Development Kit'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.code), text: 'Smart Contracts'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Wallet'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.swap_horiz), text: 'DeFi'),
            Tab(icon: Icon(Icons.token), text: 'NFT'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSmartContractTab(),
          _buildWalletTab(),
          _buildAnalyticsTab(),
          _buildDeFiTab(),
          _buildNFTTab(),
        ],
      ),
    );
  }

  Widget _buildSmartContractTab() {
    return Column(
      children: [
        // Network and Language Selection
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade500],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedNetwork,
                  dropdownColor: Colors.deepPurple.shade300,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Network',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  items: _networks.map((network) {
                    return DropdownMenuItem(
                      value: network,
                      child: Text(network),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedNetwork = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  dropdownColor: Colors.deepPurple.shade300,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  items: _languages.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                      _contractController.text = _getSampleContract();
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // Contract Editor
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Smart Contract Editor',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _compileContract,
                        icon: const Icon(Icons.build, size: 16),
                        label: const Text('Compile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _deployContract,
                        icon: const Icon(Icons.cloud_upload, size: 16),
                        label: const Text('Deploy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _contractController,
                    maxLines: null,
                    expands: true,
                    style: GoogleFonts.jetBrainsMono(fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Compilation Results
        if (_compilationResult.isNotEmpty)
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compilation Results',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _compilationResult,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Quick Actions
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildQuickActionChip('ERC20 Token', Icons.token, () {
                _loadTemplate('erc20');
              }),
              _buildQuickActionChip('ERC721 NFT', Icons.image, () {
                _loadTemplate('erc721');
              }),
              _buildQuickActionChip('ERC1155 Multi', Icons.layers, () {
                _loadTemplate('erc1155');
              }),
              _buildQuickActionChip('DeFi Pool', Icons.pool, () {
                _loadTemplate('defi');
              }),
              _buildQuickActionChip('DAO Contract', Icons.how_to_vote, () {
                _loadTemplate('dao');
              }),
              _buildQuickActionChip('Staking', Icons.savings, () {
                _loadTemplate('staking');
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Wallet Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 32),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Development Wallet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('0x742d35Cc6634C0532...'),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.qr_code),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Generate Wallet'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.import_export),
                          label: const Text('Import Wallet'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Token Balances
          const Text(
            'Token Balances',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          ..._buildTokenBalances(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Blockchain Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Gas Price', '25 Gwei', Icons.local_gas_station),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Block Height', '18,542,123', Icons.height),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Transaction History
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          ..._buildTransactionHistory(),
        ],
      ),
    );
  }

  Widget _buildDeFiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DeFi Tools',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // DeFi Protocol Cards
          ..._buildDeFiProtocols(),
        ],
      ),
    );
  }

  Widget _buildNFTTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NFT Creator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // NFT Creation Tools
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'NFT Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Image'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.create),
                          label: const Text('Mint NFT'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.deepPurple.shade50,
      labelStyle: TextStyle(color: Colors.deepPurple.shade700),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTokenBalances() {
    final tokens = [
      {'name': 'Ethereum', 'symbol': 'ETH', 'balance': '1.25', 'value': '\$2,500'},
      {'name': 'USDC', 'symbol': 'USDC', 'balance': '1,000', 'value': '\$1,000'},
      {'name': 'Chainlink', 'symbol': 'LINK', 'balance': '50', 'value': '\$750'},
    ];

    return tokens.map((token) {
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            child: Text(token['symbol']!.substring(0, 2)),
          ),
          title: Text(token['name']!),
          subtitle: Text('${token['balance']} ${token['symbol']}'),
          trailing: Text(
            token['value']!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildTransactionHistory() {
    final transactions = [
      {'hash': '0x1234...', 'type': 'Send', 'amount': '0.5 ETH', 'status': 'Confirmed'},
      {'hash': '0x5678...', 'type': 'Receive', 'amount': '100 USDC', 'status': 'Confirmed'},
      {'hash': '0x9abc...', 'type': 'Deploy', 'amount': 'Contract', 'status': 'Pending'},
    ];

    return transactions.map((tx) {
      return Card(
        child: ListTile(
          leading: Icon(
            tx['type'] == 'Send' ? Icons.arrow_upward : 
            tx['type'] == 'Receive' ? Icons.arrow_downward : Icons.code,
            color: tx['status'] == 'Confirmed' ? Colors.green : Colors.orange,
          ),
          title: Text('${tx['type']} - ${tx['hash']}'),
          subtitle: Text(tx['amount']!),
          trailing: Chip(
            label: Text(tx['status']!),
            backgroundColor: tx['status'] == 'Confirmed' ? 
              Colors.green.shade100 : Colors.orange.shade100,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildDeFiProtocols() {
    final protocols = [
      {'name': 'Uniswap', 'type': 'DEX', 'tvl': '\$5.2B'},
      {'name': 'Compound', 'type': 'Lending', 'tvl': '\$2.1B'},
      {'name': 'Aave', 'type': 'Lending', 'tvl': '\$8.5B'},
    ];

    return protocols.map((protocol) {
      return Card(
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.account_balance),
          ),
          title: Text(protocol['name']!),
          subtitle: Text(protocol['type']!),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TVL',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                protocol['tvl']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          onTap: () {
            // Navigate to protocol details
          },
        ),
      );
    }).toList();
  }

  void _compileContract() {
    setState(() {
      _compilationResult = '''
Compiling contract for $_selectedNetwork using $_selectedLanguage...

✅ Compilation successful!
Contract: MyContract
Bytecode: 0x608060405234801561001057600080fd5b50...
ABI: [{"inputs":[],"name":"name","outputs":[{"internalType":"string",...}]
Gas estimate: 1,234,567
Size: 12.5 KB

No warnings or errors found.
''';
    });
  }

  void _deployContract() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deploying contract to testnet...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _loadTemplate(String template) {
    String templateCode;
    switch (template) {
      case 'erc20':
        templateCode = _getERC20Template();
        break;
      case 'erc721':
        templateCode = _getERC721Template();
        break;
      case 'erc1155':
        templateCode = _getERC1155Template();
        break;
      case 'defi':
        templateCode = _getDeFiTemplate();
        break;
      case 'dao':
        templateCode = _getDAOTemplate();
        break;
      case 'staking':
        templateCode = _getStakingTemplate();
        break;
      default:
        templateCode = _getSampleContract();
    }
    
    setState(() {
      _contractController.text = templateCode;
    });
  }

  String _getSampleContract() {
    switch (_selectedLanguage) {
      case 'Solidity':
        return '''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract RosToken {
    string public name = "ROS Token";
    string public symbol = "ROS";
    uint256 public totalSupply = 1000000;
    
    mapping(address => uint256) public balanceOf;
    
    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}''';
      case 'Vyper':
        return '''# @version ^0.3.7

name: public(String[64])
symbol: public(String[32])
totalSupply: public(uint256)
balanceOf: public(HashMap[address, uint256])

@external
def __init__():
    self.name = "ROS Token"
    self.symbol = "ROS"
    self.totalSupply = 1000000
    self.balanceOf[msg.sender] = self.totalSupply

@external
def transfer(_to: address, _value: uint256) -> bool:
    assert self.balanceOf[msg.sender] >= _value
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    return True''';
      default:
        return _getSampleContract();
    }
  }

  String _getERC20Template() {
    return '''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ERC20Token is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    string public name;
    string public symbol;
    
    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        _totalSupply = _initialSupply;
        _balances[msg.sender] = _initialSupply;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        
        _transfer(from, to, amount);
        _approve(from, msg.sender, currentAllowance - amount);
        
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        _balances[from] = fromBalance - amount;
        _balances[to] += amount;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        _allowances[owner][spender] = amount;
    }
}''';
  }

  String _getERC721Template() {
    return '''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ERC721NFT {
    string public name;
    string public symbol;
    uint256 private _tokenIdCounter;
    
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
    
    function mint(address to, string memory uri) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        
        return tokenId;
    }
    
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        
        _balances[to] += 1;
        _owners[tokenId] = to;
    }
    
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }
}''';
  }

  String _getERC1155Template() {
    return '''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ERC1155Multi {
    mapping(uint256 => mapping(address => uint256)) private _balances;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;
    
    function balanceOf(address account, uint256 id) public view returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }
    
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public view returns (uint256[] memory) {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");
        
        uint256[] memory batchBalances = new uint256[](accounts.length);
        
        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }
        
        return batchBalances;
    }
    
    function mint(address to, uint256 id, uint256 amount, bytes memory data) public {
        require(to != address(0), "ERC1155: mint to the zero address");
        
        _balances[id][to] += amount;
    }
    
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        
        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }
    }
}''';
  }

  String _getDeFiTemplate() {
    return '''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract LiquidityPool {
    IERC20 public tokenA;
    IERC20 public tokenB;
    
    uint256 public reserveA;
    uint256 public reserveB;
    
    mapping(address => uint256) public liquidityTokens;
    uint256 public totalLiquidity;
    
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Invalid amounts");
        
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);
        
        uint256 liquidity;
        if (totalLiquidity == 0) {
            liquidity = sqrt(amountA * amountB);
        } else {
            liquidity = min(
                (amountA * totalLiquidity) / reserveA,
                (amountB * totalLiquidity) / reserveB
            );
        }
        
        liquidityTokens[msg.sender] += liquidity;
        totalLiquidity += liquidity;
        
        reserveA += amountA;
        reserveB += amountB;
    }
    
    function swap(uint256 amountAIn, uint256 amountBIn) external {
        require(amountAIn > 0 || amountBIn > 0, "Invalid swap amounts");
        require(amountAIn == 0 || amountBIn == 0, "Only one token can be swapped at a time");
        
        uint256 amountOut;
        if (amountAIn > 0) {
            amountOut = getAmountOut(amountAIn, reserveA, reserveB);
            tokenA.transferFrom(msg.sender, address(this), amountAIn);
            tokenB.transfer(msg.sender, amountOut);
            reserveA += amountAIn;
            reserveB -= amountOut;
        } else {
            amountOut = getAmountOut(amountBIn, reserveB, reserveA);
            tokenB.transferFrom(msg.sender, address(this), amountBIn);
            tokenA.transfer(msg.sender, amountOut);
            reserveB += amountBIn;
            reserveA -= amountOut;
        }
    }
    
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) 
        public pure returns (uint256) {
        require(amountIn > 0, "Insufficient input amount");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity");
        
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        
        return numerator / denominator;
    }
    
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}''';
  }

  String _getDAOTemplate() {
    return '''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleDAO {
    struct Proposal {
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        bool executed;
        mapping(address => bool) hasVoted;
    }
    
    mapping(address => uint256) public shares;
    mapping(uint256 => Proposal) public proposals;
    uint256 public totalShares;
    uint256 public proposalCount;
    
    uint256 public constant VOTING_PERIOD = 7 days;
    uint256 public constant QUORUM = 51; // 51% quorum
    
    modifier onlyMember() {
        require(shares[msg.sender] > 0, "Not a member");
        _;
    }
    
    function joinDAO() external payable {
        require(msg.value > 0, "Must send ETH to join");
        shares[msg.sender] += msg.value;
        totalShares += msg.value;
    }
    
    function createProposal(string memory description) external onlyMember {
        uint256 proposalId = proposalCount++;
        Proposal storage proposal = proposals[proposalId];
        proposal.description = description;
        proposal.deadline = block.timestamp + VOTING_PERIOD;
    }
    
    function vote(uint256 proposalId, bool support) external onlyMember {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp < proposal.deadline, "Voting period ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");
        
        proposal.hasVoted[msg.sender] = true;
        
        if (support) {
            proposal.votesFor += shares[msg.sender];
        } else {
            proposal.votesAgainst += shares[msg.sender];
        }
    }
    
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.deadline, "Voting period not ended");
        require(!proposal.executed, "Proposal already executed");
        
        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        require(totalVotes * 100 >= totalShares * QUORUM, "Quorum not reached");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal rejected");
        
        proposal.executed = true;
        // Execute proposal logic here
    }
}''';
  }

  String _getStakingTemplate() {
    return '''// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenStaking {
    IERC20 public stakingToken;
    IERC20 public rewardToken;
    
    uint256 public rewardRate = 100; // tokens per second
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public balances;
    
    uint256 public totalSupply;
    
    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }
    
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + 
            (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / totalSupply);
    }
    
    function earned(address account) public view returns (uint256) {
        return ((balances[account] * 
            (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) + 
            rewards[account];
    }
    
    function stake(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        totalSupply += amount;
        balances[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }
    
    function withdraw(uint256 amount) external updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        totalSupply -= amount;
        balances[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
    }
    
    function claimReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
        }
    }
    
    function exit() external {
        withdraw(balances[msg.sender]);
        claimReward();
    }
}''';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contractController.dispose();
    super.dispose();
  }
}