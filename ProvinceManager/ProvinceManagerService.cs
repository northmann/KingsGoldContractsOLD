using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Web3;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts.ContractHandlers;
using Nethereum.Contracts;
using System.Threading;
using KingsGoldContracts.Contracts.ProvinceManager.ContractDefinition;

namespace KingsGoldContracts.Contracts.ProvinceManager
{
    public partial class ProvinceManagerService
    {
        public static Task<TransactionReceipt> DeployContractAndWaitForReceiptAsync(Nethereum.Web3.Web3 web3, ProvinceManagerDeployment provinceManagerDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            return web3.Eth.GetContractDeploymentHandler<ProvinceManagerDeployment>().SendRequestAndWaitForReceiptAsync(provinceManagerDeployment, cancellationTokenSource);
        }

        public static Task<string> DeployContractAsync(Nethereum.Web3.Web3 web3, ProvinceManagerDeployment provinceManagerDeployment)
        {
            return web3.Eth.GetContractDeploymentHandler<ProvinceManagerDeployment>().SendRequestAsync(provinceManagerDeployment);
        }

        public static async Task<ProvinceManagerService> DeployContractAndGetServiceAsync(Nethereum.Web3.Web3 web3, ProvinceManagerDeployment provinceManagerDeployment, CancellationTokenSource cancellationTokenSource = null)
        {
            var receipt = await DeployContractAndWaitForReceiptAsync(web3, provinceManagerDeployment, cancellationTokenSource);
            return new ProvinceManagerService(web3, receipt.ContractAddress);
        }

        protected Nethereum.Web3.Web3 Web3{ get; }

        public ContractHandler ContractHandler { get; }

        public ProvinceManagerService(Nethereum.Web3.Web3 web3, string contractAddress)
        {
            Web3 = web3;
            ContractHandler = web3.Eth.GetContractHandler(contractAddress);
        }

        public Task<byte[]> DefaultAdminRoleQueryAsync(DefaultAdminRoleFunction defaultAdminRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<DefaultAdminRoleFunction, byte[]>(defaultAdminRoleFunction, blockParameter);
        }

        
        public Task<byte[]> DefaultAdminRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<DefaultAdminRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> EventRoleQueryAsync(EventRoleFunction eventRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<EventRoleFunction, byte[]>(eventRoleFunction, blockParameter);
        }

        
        public Task<byte[]> EventRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<EventRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> MinterRoleQueryAsync(MinterRoleFunction minterRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MinterRoleFunction, byte[]>(minterRoleFunction, blockParameter);
        }

        
        public Task<byte[]> MinterRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<MinterRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> OwnerRoleQueryAsync(OwnerRoleFunction ownerRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<OwnerRoleFunction, byte[]>(ownerRoleFunction, blockParameter);
        }

        
        public Task<byte[]> OwnerRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<OwnerRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> PauserRoleQueryAsync(PauserRoleFunction pauserRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<PauserRoleFunction, byte[]>(pauserRoleFunction, blockParameter);
        }

        
        public Task<byte[]> PauserRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<PauserRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> ProvinceRoleQueryAsync(ProvinceRoleFunction provinceRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ProvinceRoleFunction, byte[]>(provinceRoleFunction, blockParameter);
        }

        
        public Task<byte[]> ProvinceRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ProvinceRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> TemporaryMinterRoleQueryAsync(TemporaryMinterRoleFunction temporaryMinterRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TemporaryMinterRoleFunction, byte[]>(temporaryMinterRoleFunction, blockParameter);
        }

        
        public Task<byte[]> TemporaryMinterRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TemporaryMinterRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> UpgraderRoleQueryAsync(UpgraderRoleFunction upgraderRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<UpgraderRoleFunction, byte[]>(upgraderRoleFunction, blockParameter);
        }

        
        public Task<byte[]> UpgraderRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<UpgraderRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> UserRoleQueryAsync(UserRoleFunction userRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<UserRoleFunction, byte[]>(userRoleFunction, blockParameter);
        }

        
        public Task<byte[]> UserRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<UserRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<byte[]> VassalRoleQueryAsync(VassalRoleFunction vassalRoleFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VassalRoleFunction, byte[]>(vassalRoleFunction, blockParameter);
        }

        
        public Task<byte[]> VassalRoleQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<VassalRoleFunction, byte[]>(null, blockParameter);
        }

        public Task<string> AddSvgResoucesRequestAsync(AddSvgResoucesFunction addSvgResoucesFunction)
        {
             return ContractHandler.SendRequestAsync(addSvgResoucesFunction);
        }

        public Task<TransactionReceipt> AddSvgResoucesRequestAndWaitForReceiptAsync(AddSvgResoucesFunction addSvgResoucesFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(addSvgResoucesFunction, cancellationToken);
        }

        public Task<string> AddSvgResoucesRequestAsync(BigInteger id, string svg)
        {
            var addSvgResoucesFunction = new AddSvgResoucesFunction();
                addSvgResoucesFunction.Id = id;
                addSvgResoucesFunction.Svg = svg;
            
             return ContractHandler.SendRequestAsync(addSvgResoucesFunction);
        }

        public Task<TransactionReceipt> AddSvgResoucesRequestAndWaitForReceiptAsync(BigInteger id, string svg, CancellationTokenSource cancellationToken = null)
        {
            var addSvgResoucesFunction = new AddSvgResoucesFunction();
                addSvgResoucesFunction.Id = id;
                addSvgResoucesFunction.Svg = svg;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(addSvgResoucesFunction, cancellationToken);
        }

        public Task<string> ApproveRequestAsync(ApproveFunction approveFunction)
        {
             return ContractHandler.SendRequestAsync(approveFunction);
        }

        public Task<TransactionReceipt> ApproveRequestAndWaitForReceiptAsync(ApproveFunction approveFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(approveFunction, cancellationToken);
        }

        public Task<string> ApproveRequestAsync(string to, BigInteger tokenId)
        {
            var approveFunction = new ApproveFunction();
                approveFunction.To = to;
                approveFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAsync(approveFunction);
        }

        public Task<TransactionReceipt> ApproveRequestAndWaitForReceiptAsync(string to, BigInteger tokenId, CancellationTokenSource cancellationToken = null)
        {
            var approveFunction = new ApproveFunction();
                approveFunction.To = to;
                approveFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(approveFunction, cancellationToken);
        }

        public Task<BigInteger> BalanceOfQueryAsync(BalanceOfFunction balanceOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BalanceOfFunction, BigInteger>(balanceOfFunction, blockParameter);
        }

        
        public Task<BigInteger> BalanceOfQueryAsync(string owner, BlockParameter blockParameter = null)
        {
            var balanceOfFunction = new BalanceOfFunction();
                balanceOfFunction.Owner = owner;
            
            return ContractHandler.QueryAsync<BalanceOfFunction, BigInteger>(balanceOfFunction, blockParameter);
        }

        public Task<string> BeaconAddressQueryAsync(BeaconAddressFunction beaconAddressFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BeaconAddressFunction, string>(beaconAddressFunction, blockParameter);
        }

        
        public Task<string> BeaconAddressQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<BeaconAddressFunction, string>(null, blockParameter);
        }

        public Task<string> BurnRequestAsync(BurnFunction burnFunction)
        {
             return ContractHandler.SendRequestAsync(burnFunction);
        }

        public Task<TransactionReceipt> BurnRequestAndWaitForReceiptAsync(BurnFunction burnFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFunction, cancellationToken);
        }

        public Task<string> BurnRequestAsync(BigInteger tokenId)
        {
            var burnFunction = new BurnFunction();
                burnFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAsync(burnFunction);
        }

        public Task<TransactionReceipt> BurnRequestAndWaitForReceiptAsync(BigInteger tokenId, CancellationTokenSource cancellationToken = null)
        {
            var burnFunction = new BurnFunction();
                burnFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(burnFunction, cancellationToken);
        }

        public Task<bool> ContainsQueryAsync(ContainsFunction containsFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ContainsFunction, bool>(containsFunction, blockParameter);
        }

        
        public Task<bool> ContainsQueryAsync(string provinceAddress, BlockParameter blockParameter = null)
        {
            var containsFunction = new ContainsFunction();
                containsFunction.ProvinceAddress = provinceAddress;
            
            return ContractHandler.QueryAsync<ContainsFunction, bool>(containsFunction, blockParameter);
        }

        public Task<string> ContinentQueryAsync(ContinentFunction continentFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ContinentFunction, string>(continentFunction, blockParameter);
        }

        
        public Task<string> ContinentQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ContinentFunction, string>(null, blockParameter);
        }

        public Task<string> GetApprovedQueryAsync(GetApprovedFunction getApprovedFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<GetApprovedFunction, string>(getApprovedFunction, blockParameter);
        }

        
        public Task<string> GetApprovedQueryAsync(BigInteger tokenId, BlockParameter blockParameter = null)
        {
            var getApprovedFunction = new GetApprovedFunction();
                getApprovedFunction.TokenId = tokenId;
            
            return ContractHandler.QueryAsync<GetApprovedFunction, string>(getApprovedFunction, blockParameter);
        }

        public Task<string> InitializeRequestAsync(InitializeFunction initializeFunction)
        {
             return ContractHandler.SendRequestAsync(initializeFunction);
        }

        public Task<TransactionReceipt> InitializeRequestAndWaitForReceiptAsync(InitializeFunction initializeFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(initializeFunction, cancellationToken);
        }

        public Task<string> InitializeRequestAsync(string userUserManager)
        {
            var initializeFunction = new InitializeFunction();
                initializeFunction.UserUserManager = userUserManager;
            
             return ContractHandler.SendRequestAsync(initializeFunction);
        }

        public Task<TransactionReceipt> InitializeRequestAndWaitForReceiptAsync(string userUserManager, CancellationTokenSource cancellationToken = null)
        {
            var initializeFunction = new InitializeFunction();
                initializeFunction.UserUserManager = userUserManager;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(initializeFunction, cancellationToken);
        }

        public Task<bool> IsApprovedForAllQueryAsync(IsApprovedForAllFunction isApprovedForAllFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<IsApprovedForAllFunction, bool>(isApprovedForAllFunction, blockParameter);
        }

        
        public Task<bool> IsApprovedForAllQueryAsync(string owner, string @operator, BlockParameter blockParameter = null)
        {
            var isApprovedForAllFunction = new IsApprovedForAllFunction();
                isApprovedForAllFunction.Owner = owner;
                isApprovedForAllFunction.Operator = @operator;
            
            return ContractHandler.QueryAsync<IsApprovedForAllFunction, bool>(isApprovedForAllFunction, blockParameter);
        }

        public Task<string> MintProvinceRequestAsync(MintProvinceFunction mintProvinceFunction)
        {
             return ContractHandler.SendRequestAsync(mintProvinceFunction);
        }

        public Task<TransactionReceipt> MintProvinceRequestAndWaitForReceiptAsync(MintProvinceFunction mintProvinceFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintProvinceFunction, cancellationToken);
        }

        public Task<string> MintProvinceRequestAsync(string name, string owner)
        {
            var mintProvinceFunction = new MintProvinceFunction();
                mintProvinceFunction.Name = name;
                mintProvinceFunction.Owner = owner;
            
             return ContractHandler.SendRequestAsync(mintProvinceFunction);
        }

        public Task<TransactionReceipt> MintProvinceRequestAndWaitForReceiptAsync(string name, string owner, CancellationTokenSource cancellationToken = null)
        {
            var mintProvinceFunction = new MintProvinceFunction();
                mintProvinceFunction.Name = name;
                mintProvinceFunction.Owner = owner;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(mintProvinceFunction, cancellationToken);
        }

        public Task<string> NameQueryAsync(NameFunction nameFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NameFunction, string>(nameFunction, blockParameter);
        }

        
        public Task<string> NameQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<NameFunction, string>(null, blockParameter);
        }

        public Task<string> OwnerOfQueryAsync(OwnerOfFunction ownerOfFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<OwnerOfFunction, string>(ownerOfFunction, blockParameter);
        }

        
        public Task<string> OwnerOfQueryAsync(BigInteger tokenId, BlockParameter blockParameter = null)
        {
            var ownerOfFunction = new OwnerOfFunction();
                ownerOfFunction.TokenId = tokenId;
            
            return ContractHandler.QueryAsync<OwnerOfFunction, string>(ownerOfFunction, blockParameter);
        }

        public Task<string> PauseRequestAsync(PauseFunction pauseFunction)
        {
             return ContractHandler.SendRequestAsync(pauseFunction);
        }

        public Task<string> PauseRequestAsync()
        {
             return ContractHandler.SendRequestAsync<PauseFunction>();
        }

        public Task<TransactionReceipt> PauseRequestAndWaitForReceiptAsync(PauseFunction pauseFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(pauseFunction, cancellationToken);
        }

        public Task<TransactionReceipt> PauseRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<PauseFunction>(null, cancellationToken);
        }

        public Task<bool> PausedQueryAsync(PausedFunction pausedFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<PausedFunction, bool>(pausedFunction, blockParameter);
        }

        
        public Task<bool> PausedQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<PausedFunction, bool>(null, blockParameter);
        }

        public Task<string> ProvincesQueryAsync(ProvincesFunction provincesFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ProvincesFunction, string>(provincesFunction, blockParameter);
        }

        
        public Task<string> ProvincesQueryAsync(BigInteger returnValue1, BlockParameter blockParameter = null)
        {
            var provincesFunction = new ProvincesFunction();
                provincesFunction.ReturnValue1 = returnValue1;
            
            return ContractHandler.QueryAsync<ProvincesFunction, string>(provincesFunction, blockParameter);
        }

        public Task<byte[]> ProxiableUUIDQueryAsync(ProxiableUUIDFunction proxiableUUIDFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ProxiableUUIDFunction, byte[]>(proxiableUUIDFunction, blockParameter);
        }

        
        public Task<byte[]> ProxiableUUIDQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<ProxiableUUIDFunction, byte[]>(null, blockParameter);
        }

        public Task<string> SafeMintRequestAsync(SafeMintFunction safeMintFunction)
        {
             return ContractHandler.SendRequestAsync(safeMintFunction);
        }

        public Task<TransactionReceipt> SafeMintRequestAndWaitForReceiptAsync(SafeMintFunction safeMintFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeMintFunction, cancellationToken);
        }

        public Task<string> SafeMintRequestAsync(string to)
        {
            var safeMintFunction = new SafeMintFunction();
                safeMintFunction.To = to;
            
             return ContractHandler.SendRequestAsync(safeMintFunction);
        }

        public Task<TransactionReceipt> SafeMintRequestAndWaitForReceiptAsync(string to, CancellationTokenSource cancellationToken = null)
        {
            var safeMintFunction = new SafeMintFunction();
                safeMintFunction.To = to;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeMintFunction, cancellationToken);
        }

        public Task<string> SafeTransferFromRequestAsync(SafeTransferFromFunction safeTransferFromFunction)
        {
             return ContractHandler.SendRequestAsync(safeTransferFromFunction);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(SafeTransferFromFunction safeTransferFromFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFromFunction, cancellationToken);
        }

        public Task<string> SafeTransferFromRequestAsync(string from, string to, BigInteger tokenId)
        {
            var safeTransferFromFunction = new SafeTransferFromFunction();
                safeTransferFromFunction.From = from;
                safeTransferFromFunction.To = to;
                safeTransferFromFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAsync(safeTransferFromFunction);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(string from, string to, BigInteger tokenId, CancellationTokenSource cancellationToken = null)
        {
            var safeTransferFromFunction = new SafeTransferFromFunction();
                safeTransferFromFunction.From = from;
                safeTransferFromFunction.To = to;
                safeTransferFromFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFromFunction, cancellationToken);
        }

        public Task<string> SafeTransferFromRequestAsync(SafeTransferFrom1Function safeTransferFrom1Function)
        {
             return ContractHandler.SendRequestAsync(safeTransferFrom1Function);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(SafeTransferFrom1Function safeTransferFrom1Function, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFrom1Function, cancellationToken);
        }

        public Task<string> SafeTransferFromRequestAsync(string from, string to, BigInteger tokenId, byte[] data)
        {
            var safeTransferFrom1Function = new SafeTransferFrom1Function();
                safeTransferFrom1Function.From = from;
                safeTransferFrom1Function.To = to;
                safeTransferFrom1Function.TokenId = tokenId;
                safeTransferFrom1Function.Data = data;
            
             return ContractHandler.SendRequestAsync(safeTransferFrom1Function);
        }

        public Task<TransactionReceipt> SafeTransferFromRequestAndWaitForReceiptAsync(string from, string to, BigInteger tokenId, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var safeTransferFrom1Function = new SafeTransferFrom1Function();
                safeTransferFrom1Function.From = from;
                safeTransferFrom1Function.To = to;
                safeTransferFrom1Function.TokenId = tokenId;
                safeTransferFrom1Function.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(safeTransferFrom1Function, cancellationToken);
        }

        public Task<string> SetApprovalForAllRequestAsync(SetApprovalForAllFunction setApprovalForAllFunction)
        {
             return ContractHandler.SendRequestAsync(setApprovalForAllFunction);
        }

        public Task<TransactionReceipt> SetApprovalForAllRequestAndWaitForReceiptAsync(SetApprovalForAllFunction setApprovalForAllFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setApprovalForAllFunction, cancellationToken);
        }

        public Task<string> SetApprovalForAllRequestAsync(string @operator, bool approved)
        {
            var setApprovalForAllFunction = new SetApprovalForAllFunction();
                setApprovalForAllFunction.Operator = @operator;
                setApprovalForAllFunction.Approved = approved;
            
             return ContractHandler.SendRequestAsync(setApprovalForAllFunction);
        }

        public Task<TransactionReceipt> SetApprovalForAllRequestAndWaitForReceiptAsync(string @operator, bool approved, CancellationTokenSource cancellationToken = null)
        {
            var setApprovalForAllFunction = new SetApprovalForAllFunction();
                setApprovalForAllFunction.Operator = @operator;
                setApprovalForAllFunction.Approved = approved;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setApprovalForAllFunction, cancellationToken);
        }

        public Task<string> SetContinentRequestAsync(SetContinentFunction setContinentFunction)
        {
             return ContractHandler.SendRequestAsync(setContinentFunction);
        }

        public Task<TransactionReceipt> SetContinentRequestAndWaitForReceiptAsync(SetContinentFunction setContinentFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setContinentFunction, cancellationToken);
        }

        public Task<string> SetContinentRequestAsync(string continent)
        {
            var setContinentFunction = new SetContinentFunction();
                setContinentFunction.Continent = continent;
            
             return ContractHandler.SendRequestAsync(setContinentFunction);
        }

        public Task<TransactionReceipt> SetContinentRequestAndWaitForReceiptAsync(string continent, CancellationTokenSource cancellationToken = null)
        {
            var setContinentFunction = new SetContinentFunction();
                setContinentFunction.Continent = continent;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setContinentFunction, cancellationToken);
        }

        public Task<string> SetProvinceBeaconRequestAsync(SetProvinceBeaconFunction setProvinceBeaconFunction)
        {
             return ContractHandler.SendRequestAsync(setProvinceBeaconFunction);
        }

        public Task<TransactionReceipt> SetProvinceBeaconRequestAndWaitForReceiptAsync(SetProvinceBeaconFunction setProvinceBeaconFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setProvinceBeaconFunction, cancellationToken);
        }

        public Task<string> SetProvinceBeaconRequestAsync(string template)
        {
            var setProvinceBeaconFunction = new SetProvinceBeaconFunction();
                setProvinceBeaconFunction.Template = template;
            
             return ContractHandler.SendRequestAsync(setProvinceBeaconFunction);
        }

        public Task<TransactionReceipt> SetProvinceBeaconRequestAndWaitForReceiptAsync(string template, CancellationTokenSource cancellationToken = null)
        {
            var setProvinceBeaconFunction = new SetProvinceBeaconFunction();
                setProvinceBeaconFunction.Template = template;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setProvinceBeaconFunction, cancellationToken);
        }

        public Task<string> SetUserAccountManagerRequestAsync(SetUserAccountManagerFunction setUserAccountManagerFunction)
        {
             return ContractHandler.SendRequestAsync(setUserAccountManagerFunction);
        }

        public Task<TransactionReceipt> SetUserAccountManagerRequestAndWaitForReceiptAsync(SetUserAccountManagerFunction setUserAccountManagerFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setUserAccountManagerFunction, cancellationToken);
        }

        public Task<string> SetUserAccountManagerRequestAsync(string userAccountManager)
        {
            var setUserAccountManagerFunction = new SetUserAccountManagerFunction();
                setUserAccountManagerFunction.UserAccountManager = userAccountManager;
            
             return ContractHandler.SendRequestAsync(setUserAccountManagerFunction);
        }

        public Task<TransactionReceipt> SetUserAccountManagerRequestAndWaitForReceiptAsync(string userAccountManager, CancellationTokenSource cancellationToken = null)
        {
            var setUserAccountManagerFunction = new SetUserAccountManagerFunction();
                setUserAccountManagerFunction.UserAccountManager = userAccountManager;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(setUserAccountManagerFunction, cancellationToken);
        }

        public Task<bool> SupportsInterfaceQueryAsync(SupportsInterfaceFunction supportsInterfaceFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SupportsInterfaceFunction, bool>(supportsInterfaceFunction, blockParameter);
        }

        
        public Task<bool> SupportsInterfaceQueryAsync(byte[] interfaceId, BlockParameter blockParameter = null)
        {
            var supportsInterfaceFunction = new SupportsInterfaceFunction();
                supportsInterfaceFunction.InterfaceId = interfaceId;
            
            return ContractHandler.QueryAsync<SupportsInterfaceFunction, bool>(supportsInterfaceFunction, blockParameter);
        }

        public Task<string> SymbolQueryAsync(SymbolFunction symbolFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SymbolFunction, string>(symbolFunction, blockParameter);
        }

        
        public Task<string> SymbolQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<SymbolFunction, string>(null, blockParameter);
        }

        public Task<BigInteger> TokenByIndexQueryAsync(TokenByIndexFunction tokenByIndexFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TokenByIndexFunction, BigInteger>(tokenByIndexFunction, blockParameter);
        }

        
        public Task<BigInteger> TokenByIndexQueryAsync(BigInteger index, BlockParameter blockParameter = null)
        {
            var tokenByIndexFunction = new TokenByIndexFunction();
                tokenByIndexFunction.Index = index;
            
            return ContractHandler.QueryAsync<TokenByIndexFunction, BigInteger>(tokenByIndexFunction, blockParameter);
        }

        public Task<BigInteger> TokenOfOwnerByIndexQueryAsync(TokenOfOwnerByIndexFunction tokenOfOwnerByIndexFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TokenOfOwnerByIndexFunction, BigInteger>(tokenOfOwnerByIndexFunction, blockParameter);
        }

        
        public Task<BigInteger> TokenOfOwnerByIndexQueryAsync(string owner, BigInteger index, BlockParameter blockParameter = null)
        {
            var tokenOfOwnerByIndexFunction = new TokenOfOwnerByIndexFunction();
                tokenOfOwnerByIndexFunction.Owner = owner;
                tokenOfOwnerByIndexFunction.Index = index;
            
            return ContractHandler.QueryAsync<TokenOfOwnerByIndexFunction, BigInteger>(tokenOfOwnerByIndexFunction, blockParameter);
        }

        public Task<string> TokenURIQueryAsync(TokenURIFunction tokenURIFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TokenURIFunction, string>(tokenURIFunction, blockParameter);
        }

        
        public Task<string> TokenURIQueryAsync(BigInteger tokenId, BlockParameter blockParameter = null)
        {
            var tokenURIFunction = new TokenURIFunction();
                tokenURIFunction.TokenId = tokenId;
            
            return ContractHandler.QueryAsync<TokenURIFunction, string>(tokenURIFunction, blockParameter);
        }

        public Task<BigInteger> TotalSupplyQueryAsync(TotalSupplyFunction totalSupplyFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(totalSupplyFunction, blockParameter);
        }

        
        public Task<BigInteger> TotalSupplyQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<TotalSupplyFunction, BigInteger>(null, blockParameter);
        }

        public Task<string> TransferFromRequestAsync(TransferFromFunction transferFromFunction)
        {
             return ContractHandler.SendRequestAsync(transferFromFunction);
        }

        public Task<TransactionReceipt> TransferFromRequestAndWaitForReceiptAsync(TransferFromFunction transferFromFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferFromFunction, cancellationToken);
        }

        public Task<string> TransferFromRequestAsync(string from, string to, BigInteger tokenId)
        {
            var transferFromFunction = new TransferFromFunction();
                transferFromFunction.From = from;
                transferFromFunction.To = to;
                transferFromFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAsync(transferFromFunction);
        }

        public Task<TransactionReceipt> TransferFromRequestAndWaitForReceiptAsync(string from, string to, BigInteger tokenId, CancellationTokenSource cancellationToken = null)
        {
            var transferFromFunction = new TransferFromFunction();
                transferFromFunction.From = from;
                transferFromFunction.To = to;
                transferFromFunction.TokenId = tokenId;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(transferFromFunction, cancellationToken);
        }

        public Task<string> UnpauseRequestAsync(UnpauseFunction unpauseFunction)
        {
             return ContractHandler.SendRequestAsync(unpauseFunction);
        }

        public Task<string> UnpauseRequestAsync()
        {
             return ContractHandler.SendRequestAsync<UnpauseFunction>();
        }

        public Task<TransactionReceipt> UnpauseRequestAndWaitForReceiptAsync(UnpauseFunction unpauseFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(unpauseFunction, cancellationToken);
        }

        public Task<TransactionReceipt> UnpauseRequestAndWaitForReceiptAsync(CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync<UnpauseFunction>(null, cancellationToken);
        }

        public Task<string> UpgradeToRequestAsync(UpgradeToFunction upgradeToFunction)
        {
             return ContractHandler.SendRequestAsync(upgradeToFunction);
        }

        public Task<TransactionReceipt> UpgradeToRequestAndWaitForReceiptAsync(UpgradeToFunction upgradeToFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(upgradeToFunction, cancellationToken);
        }

        public Task<string> UpgradeToRequestAsync(string newImplementation)
        {
            var upgradeToFunction = new UpgradeToFunction();
                upgradeToFunction.NewImplementation = newImplementation;
            
             return ContractHandler.SendRequestAsync(upgradeToFunction);
        }

        public Task<TransactionReceipt> UpgradeToRequestAndWaitForReceiptAsync(string newImplementation, CancellationTokenSource cancellationToken = null)
        {
            var upgradeToFunction = new UpgradeToFunction();
                upgradeToFunction.NewImplementation = newImplementation;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(upgradeToFunction, cancellationToken);
        }

        public Task<string> UpgradeToAndCallRequestAsync(UpgradeToAndCallFunction upgradeToAndCallFunction)
        {
             return ContractHandler.SendRequestAsync(upgradeToAndCallFunction);
        }

        public Task<TransactionReceipt> UpgradeToAndCallRequestAndWaitForReceiptAsync(UpgradeToAndCallFunction upgradeToAndCallFunction, CancellationTokenSource cancellationToken = null)
        {
             return ContractHandler.SendRequestAndWaitForReceiptAsync(upgradeToAndCallFunction, cancellationToken);
        }

        public Task<string> UpgradeToAndCallRequestAsync(string newImplementation, byte[] data)
        {
            var upgradeToAndCallFunction = new UpgradeToAndCallFunction();
                upgradeToAndCallFunction.NewImplementation = newImplementation;
                upgradeToAndCallFunction.Data = data;
            
             return ContractHandler.SendRequestAsync(upgradeToAndCallFunction);
        }

        public Task<TransactionReceipt> UpgradeToAndCallRequestAndWaitForReceiptAsync(string newImplementation, byte[] data, CancellationTokenSource cancellationToken = null)
        {
            var upgradeToAndCallFunction = new UpgradeToAndCallFunction();
                upgradeToAndCallFunction.NewImplementation = newImplementation;
                upgradeToAndCallFunction.Data = data;
            
             return ContractHandler.SendRequestAndWaitForReceiptAsync(upgradeToAndCallFunction, cancellationToken);
        }

        public Task<string> UserAccountManagerQueryAsync(UserAccountManagerFunction userAccountManagerFunction, BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<UserAccountManagerFunction, string>(userAccountManagerFunction, blockParameter);
        }

        
        public Task<string> UserAccountManagerQueryAsync(BlockParameter blockParameter = null)
        {
            return ContractHandler.QueryAsync<UserAccountManagerFunction, string>(null, blockParameter);
        }
    }
}
