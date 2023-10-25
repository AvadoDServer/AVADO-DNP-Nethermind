#!/bin/sh

JWT_TOKEN="/nethermind/keystore/jwt-secret"
until $(curl --silent --fail "http://dappmanager.my.ava.do/jwttoken.txt" --output "${JWT_TOKEN}"); do
  echo "Waiting for the JWT Token"
  sleep 5
done

echo "EXTRA_OPTS=$EXTRA_OPTS"

#handle rename from "xdai" to "gnosis"
if [ "${NETWORK}" = "gnosis" ]; then
  if [ -d "/nethermind/nethermind_db/xdai" ] && [ ! -d "/nethermind/nethermind_db/gnosis" ]; then
    echo "Network was updated from \"xdai\" to \"gnosis\": updating database folder"
    mv /nethermind/nethermind_db/xdai /nethermind/nethermind_db/gnosis
  fi
fi

case ${NETWORK} in
"gnosis" | "xdai")
  P2P_PORT=30305
  DISCOVERY_BOOTNODES="enode://a8558c4449bdb4ed47b8fd0ceaee8cf56272cd308e98e693a838d58b9abd2411b71b9b7e2d63a50b140fd9b0a2e05e83f338c3906dd925e9f178f0feda0c4ca7@165.232.138.187:30303,enode://e52280c512cd1f023135d7f70f31904bda7bb699d4300346182a2e3fc5a07637c25cc4349b48101ffe2fe6229b3b165ed7929ad9db971d847d02e21192989ce5@143.198.156.24:30303,enode://8ed1893f617f1ed2c6a978fa92fa38ac19db6de5596c93bf21921c40ed34f63b63a93234ddedf9b385192dd7aa652e1d4b55efed299961b0ae5d4318ecb985ec@159.223.213.61:30303,enode://cc3f99a19360edd73f91f04c6fe728ff8da431f8445a35c02a0fd99fee2be5d9f5ea75a416b08f4a019e0a0d3afa8aece93a560bbe3ce0509eec54bbddc00bb8@178.62.194.136:30303,enode://8f3a63b270cd32692f5b825874b9f3acef3cf90dec40fe54848267f568b7275349efb830812c1b24f1781774f745fb00e595d2feef642fd6867e173f05108cc4@178.62.192.195:30303,enode://075d567bcc5b6bbcb5c9922bf7f17a706408bed141dcefb5d387cfe6e0c7c9407e450a5d17b9180b25fb07b3e82943639d011752ea44a2d868b3c37f48a318b9@167.99.209.14:30303,enode://bb19f1fcf0d0667d9752bec2f4230e24331a7764e5a73a41006378861ef79f9a4386f646e239e1842e4bb721ade9369be8f2fd81b407d9febec2e150ccb7f257@137.184.228.83:30303,enode://529cc11acd013d5e92aa38d4139636619285b2bb4221bcdf7c5dbf171e828d05b88934e6154b984f8164953d7d7530b49c6d0e030fade3a3737d28092a289704@164.92.96.111:30303,enode://9d41c6f8c77a1ac3069cc9326068c04465b9fc56abaaf84fa753fc723511f278dd1d65c22753eb60dfd95f60fe942d0f670c490660e3d6cd518ddafb986682d2@178.62.196.104:30303,enode://874ac7df642fc2abffcca71991c3646a5634a415a4a6513112a89429f7ae43914ad6f1d2ea73a96a19f302c17a7c5e07a0dd01fed70c9294a6fd5615b86710b7@159.223.213.166:30303,enode://5d1a11b5f19afb7d2d04406a4877ed7de92a4ca898ee0d36ff54729b99664e4ac787877e553043a38a38f878aab43fc0d757673e0c11ee8eb606f1ea4681ce3c@147.182.204.197:30303,enode://144d125c790100f6405d957dea8c3a1647199109d915889e90d7f6c2940c8737b16e68e2a3af57327971ec28ed77408f9bc96035b2589da6496f3112ec72e037@137.184.183.65:30303,enode://ac8e8a62f5b54c35f4d7eb565079e9c81e241a150c0d6b2bb5bb32b068e8e4930b14a5b504f77d34014c8e9f14ec0307cc6b239e8c56be85fdcc68d4956cce7c@159.223.213.157:30303,enode://20b0de013d851ae5b667f41a923f2856420161fe0a46030cdea6d81db8da3c5b04070834219a2a6ca41d8f2c6c813870414ce473ab25736742163b0be6191861@159.223.209.185:30303,enode://3c8de197987eb896488ed60037b44c5201878d7cb47d22a322d6d73b999b1d5482820e0456dc08676665ba1ce96906900a2b5f830b2eea73730ca7532c227c7b@159.223.217.249:30303,enode://644ad8205801f9dba1d6eff107590d49479d5276c8d078f8631f351a2077d70b7bed2822219cb1c7590ba68149b89751968a45236e7d02c1025e493d647dd776@159.223.213.162:3030"
  NETWORK="gnosis"
  ;;
"goerli")
  P2P_PORT=30309
  ;;
*)
  P2P_PORT=40303
  ;;
esac

exec /nethermind/nethermind \
  --JsonRpc.JwtSecretFile ${JWT_TOKEN} \
  --JsonRpc.EnginePort=8551 \
  --JsonRpc.EngineHost=0.0.0.0 \
  --Network.DiscoveryPort ${P2P_PORT} \
  --Network.P2PPort ${P2P_PORT} \
  --config ${NETWORK} \
  --JsonRpc.Enabled=true \
  --JsonRpc.Host=0.0.0.0 \
  --Init.WebSocketsEnabled=true \
  --HealthChecks.Enabled=true \
  --HealthChecks.UIEnabled=true \
  ${DISCOVERY_BOOTNODES:+--Discovery.Bootnodes ${DISCOVERY_BOOTNODES}} \
  $EXTRA_OPTS

# Usage: Nethermind.Runner [options]

# Options:
#   -?|-h|--help                                                 Show help information
#   -v|--version                                                 Show version information
#   -dd|--datadir <dataDir>                                      Data directory
#   -c|--config <configFile>                                     Config file path
#   -d|--baseDbPath <baseDbPath>                                 Base db path
#   -l|--log <logLevel>                                          Log level override. Possible values: OFF|TRACE|DEBUG|INFO|WARN|ERROR
#   -cd|--configsDirectory <configsDirectory>                    Configs directory
#   -lcs|--loggerConfigSource <loggerConfigSource>               Path to the NLog config file
#   -pd|--pluginsDirectory <pluginsDirectory>                    plugins directory
#   --AccountAbstraction.AaPriorityPeersMaxCount                 Max number of priority AccountAbstraction peers. (DEFAULT: 20)
#   --AccountAbstraction.Enabled                                 Defines whether UserOperations are allowed. (DEFAULT: false)
#   --AccountAbstraction.EntryPointContractAddresses             Defines the comma separated list of hex string representations of the addresses of the EntryPoint contract to which transactions can be made (DEFAULT: )
#   --AccountAbstraction.FlashbotsEndpoint                       Defines the string URL for the flashbots bundle reception endpoint (DEFAULT: https://relay.flashbots.net/)
#   --AccountAbstraction.MaximumUserOperationPerSender           Defines the maximum number of UserOperations that can be kept for each sender (DEFAULT: 1)
#   --AccountAbstraction.MinimumGasPrice                         Defines the minimum gas price for a user operation to be accepted (DEFAULT: 1)
#   --AccountAbstraction.UserOperationPoolSize                   Defines the maximum number of UserOperations that can be kept in memory by clients (DEFAULT: 200)
#   --AccountAbstraction.WhitelistedPaymasters                   Defines a comma separated list of the hex string representations of paymasters that are whitelisted by the node (DEFAULT: )
#   --Aura.AllowAuRaPrivateChains                                If 'true' then you can run Nethermind only private chains. Do not use with existing Parity AuRa chains. (DEFAULT: false)
#   --Aura.ForceSealing                                          If 'true' then Nethermind if mining will seal empty blocks. (DEFAULT: true)
#   --Aura.Minimum2MlnGasPerBlockWhenUsingBlockGasLimitContract  If 'true' then when using BlockGasLimitContractTransitions if the contract returns less than 2mln gas, then 2 mln gas is used. (DEFAULT: false)
#   --Aura.TxPriorityConfigFilePath                              If set then transaction priority rules are used when selecting transactions from transaction pool. This has higher priority then on chain contract rules. See more at contract details https://github.com/poanetwork/posdao-contracts/blob/master/contracts/TxPriority.sol (DEFAULT: null)
#   --Aura.TxPriorityContractAddress                             If set then transaction priority contract is used when selecting transactions from transaction pool. See more at https://github.com/poanetwork/posdao-contracts/blob/master/contracts/TxPriority.sol (DEFAULT: null)
#   --Blocks.ExtraData                                           Block header extra data. 32-bytes shall be extra data max length. (DEFAULT: Nethermind)
#   --Blocks.MinGasPrice                                         Minimum gas premium for transactions accepted by the block producer. Before EIP1559: Minimum gas price for transactions accepted by the block producer. (DEFAULT: 1)
#   --Blocks.RandomizedBlocks                                    Only used in NethDev. Setting this to true will change the difficulty of the block randomly within the constraints. (DEFAULT: false)
#   --Blocks.SecondsPerSlot                                      Seconds per slot. (DEFAULT: 12)
#   --Blocks.TargetBlockGasLimit                                 Block gas limit that the block producer should try to reach in the fastest possible way based on protocol rules. NULL value means that the miner should follow other miners. (DEFAULT: null)
#   --Bloom.Index                                                Defines whether the Bloom index is used. Bloom index speeds up rpc log searches. (DEFAULT: true)
#   --Bloom.IndexLevelBucketSizes                                Defines multipliers for index levels. Can be tweaked per chain to boost performance. (DEFAULT: [4, 8, 8])
#   --Bloom.Migration                                            Defines if migration of previously downloaded blocks to Bloom index will be done. (DEFAULT: false)
#   --Bloom.MigrationStatistics                                  Defines if migration statistics are to be calculated and output. (DEFAULT: false)
#   --Db.AdditionalRocksDbOptions                                <missing documentation>
#   --Db.BlockCacheSize                                          <missing documentation>
#   --Db.BlockInfosDbAdditionalRocksDbOptions                    <missing documentation>
#   --Db.BlockInfosDbBlockCacheSize                              <missing documentation>
#   --Db.BlockInfosDbBlockSize                                   <missing documentation>
#   --Db.BlockInfosDbCacheIndexAndFilterBlocks                   <missing documentation>
#   --Db.BlockInfosDbCompactionReadAhead                         <missing documentation>
#   --Db.BlockInfosDbMaxBytesPerSec                              <missing documentation>
#   --Db.BlockInfosDbMaxOpenFiles                                <missing documentation>
#   --Db.BlockInfosDbUseDirectIoForFlushAndCompactions           <missing documentation>
#   --Db.BlockInfosDbUseDirectReads                              <missing documentation>
#   --Db.BlockInfosDbWriteBufferNumber                           <missing documentation>
#   --Db.BlockInfosDbWriteBufferSize                             <missing documentation>
#   --Db.BlockSize                                               <missing documentation>
#   --Db.BlocksBlockSize                                         <missing documentation>
#   --Db.BlocksDbAdditionalRocksDbOptions                        <missing documentation>
#   --Db.BlocksDbBlockCacheSize                                  <missing documentation>
#   --Db.BlocksDbCacheIndexAndFilterBlocks                       <missing documentation>
#   --Db.BlocksDbCompactionReadAhead                             <missing documentation>
#   --Db.BlocksDbMaxBytesPerSec                                  <missing documentation>
#   --Db.BlocksDbMaxOpenFiles                                    <missing documentation>
#   --Db.BlocksDbUseDirectIoForFlushAndCompactions               <missing documentation>
#   --Db.BlocksDbUseDirectReads                                  <missing documentation>
#   --Db.BlocksDbWriteBufferNumber                               <missing documentation>
#   --Db.BlocksDbWriteBufferSize                                 <missing documentation>
#   --Db.BloomDbAdditionalRocksDbOptions                         <missing documentation>
#   --Db.BloomDbBlockCacheSize                                   <missing documentation>
#   --Db.BloomDbCacheIndexAndFilterBlocks                        <missing documentation>
#   --Db.BloomDbMaxBytesPerSec                                   <missing documentation>
#   --Db.BloomDbMaxOpenFiles                                     <missing documentation>
#   --Db.BloomDbWriteBufferNumber                                <missing documentation>
#   --Db.BloomDbWriteBufferSize                                  <missing documentation>
#   --Db.CacheIndexAndFilterBlocks                               <missing documentation>
#   --Db.CanonicalHashTrieCompactionReadAhead                    <missing documentation>
#   --Db.CanonicalHashTrieDbAdditionalRocksDbOptions             <missing documentation>
#   --Db.CanonicalHashTrieDbBlockCacheSize                       <missing documentation>
#   --Db.CanonicalHashTrieDbBlockSize                            <missing documentation>
#   --Db.CanonicalHashTrieDbCacheIndexAndFilterBlocks            <missing documentation>
#   --Db.CanonicalHashTrieDbMaxBytesPerSec                       <missing documentation>
#   --Db.CanonicalHashTrieDbMaxOpenFiles                         <missing documentation>
#   --Db.CanonicalHashTrieDbWriteBufferNumber                    <missing documentation>
#   --Db.CanonicalHashTrieDbWriteBufferSize                      <missing documentation>
#   --Db.CanonicalHashTrieUseDirectIoForFlushAndCompactions      <missing documentation>
#   --Db.CanonicalHashTrieUseDirectReads                         <missing documentation>
#   --Db.CodeCompactionReadAhead                                 <missing documentation>
#   --Db.CodeDbAdditionalRocksDbOptions                          <missing documentation>
#   --Db.CodeDbBlockCacheSize                                    <missing documentation>
#   --Db.CodeDbBlockSize                                         <missing documentation>
#   --Db.CodeDbCacheIndexAndFilterBlocks                         <missing documentation>
#   --Db.CodeDbMaxBytesPerSec                                    <missing documentation>
#   --Db.CodeDbMaxOpenFiles                                      <missing documentation>
#   --Db.CodeDbWriteBufferNumber                                 <missing documentation>
#   --Db.CodeDbWriteBufferSize                                   <missing documentation>
#   --Db.CodeUseDirectIoForFlushAndCompactions                   <missing documentation>
#   --Db.CodeUseDirectReads                                      <missing documentation>
#   --Db.CompactionReadAhead                                     <missing documentation>
#   --Db.DisableCompression                                      <missing documentation>
#   --Db.EnableDbStatistics                                      <missing documentation>
#   --Db.EnableMetricsUpdater                                    <missing documentation>
#   --Db.HeadersDbAdditionalRocksDbOptions                       <missing documentation>
#   --Db.HeadersDbBlockCacheSize                                 <missing documentation>
#   --Db.HeadersDbBlockSize                                      <missing documentation>
#   --Db.HeadersDbCacheIndexAndFilterBlocks                      <missing documentation>
#   --Db.HeadersDbCompactionReadAhead                            <missing documentation>
#   --Db.HeadersDbMaxBytesPerSec                                 <missing documentation>
#   --Db.HeadersDbMaxOpenFiles                                   <missing documentation>
#   --Db.HeadersDbUseDirectIoForFlushAndCompactions              <missing documentation>
#   --Db.HeadersDbUseDirectReads                                 <missing documentation>
#   --Db.HeadersDbWriteBufferNumber                              <missing documentation>
#   --Db.HeadersDbWriteBufferSize                                <missing documentation>
#   --Db.MaxBytesPerSec                                          <missing documentation>
#   --Db.MaxOpenFiles                                            <missing documentation>
#   --Db.MetadataCompactionReadAhead                             <missing documentation>
#   --Db.MetadataDbAdditionalRocksDbOptions                      <missing documentation>
#   --Db.MetadataDbBlockCacheSize                                <missing documentation>
#   --Db.MetadataDbBlockSize                                     <missing documentation>
#   --Db.MetadataDbCacheIndexAndFilterBlocks                     <missing documentation>
#   --Db.MetadataDbMaxBytesPerSec                                <missing documentation>
#   --Db.MetadataDbMaxOpenFiles                                  <missing documentation>
#   --Db.MetadataDbWriteBufferNumber                             <missing documentation>
#   --Db.MetadataDbWriteBufferSize                               <missing documentation>
#   --Db.MetadataUseDirectIoForFlushAndCompactions               <missing documentation>
#   --Db.MetadataUseDirectReads                                  <missing documentation>
#   --Db.PendingTxsDbAdditionalRocksDbOptions                    <missing documentation>
#   --Db.PendingTxsDbBlockCacheSize                              <missing documentation>
#   --Db.PendingTxsDbBlockSize                                   <missing documentation>
#   --Db.PendingTxsDbCacheIndexAndFilterBlocks                   <missing documentation>
#   --Db.PendingTxsDbCompactionReadAhead                         <missing documentation>
#   --Db.PendingTxsDbMaxBytesPerSec                              <missing documentation>
#   --Db.PendingTxsDbMaxOpenFiles                                <missing documentation>
#   --Db.PendingTxsDbUseDirectIoForFlushAndCompactions           <missing documentation>
#   --Db.PendingTxsDbUseDirectReads                              <missing documentation>
#   --Db.PendingTxsDbWriteBufferNumber                           <missing documentation>
#   --Db.PendingTxsDbWriteBufferSize                             <missing documentation>
#   --Db.ReadAheadSize                                           <missing documentation>
#   --Db.ReceiptsDbAdditionalRocksDbOptions                      <missing documentation>
#   --Db.ReceiptsDbBlockCacheSize                                <missing documentation>
#   --Db.ReceiptsDbBlockSize                                     <missing documentation>
#   --Db.ReceiptsDbCacheIndexAndFilterBlocks                     <missing documentation>
#   --Db.ReceiptsDbCompactionReadAhead                           <missing documentation>
#   --Db.ReceiptsDbMaxBytesPerSec                                <missing documentation>
#   --Db.ReceiptsDbMaxOpenFiles                                  <missing documentation>
#   --Db.ReceiptsDbUseDirectIoForFlushAndCompactions             <missing documentation>
#   --Db.ReceiptsDbUseDirectReads                                <missing documentation>
#   --Db.ReceiptsDbWriteBufferNumber                             <missing documentation>
#   --Db.ReceiptsDbWriteBufferSize                               <missing documentation>
#   --Db.RecycleLogFileNum                                       <missing documentation>
#   --Db.SharedBlockCacheSize                                    <missing documentation>
#   --Db.SkipMemoryHintSetting                                   <missing documentation>
#   --Db.StateDbAdditionalRocksDbOptions                         <missing documentation>
#   --Db.StateDbBlockCacheSize                                   <missing documentation>
#   --Db.StateDbBlockSize                                        <missing documentation>
#   --Db.StateDbCacheIndexAndFilterBlocks                        <missing documentation>
#   --Db.StateDbCompactionReadAhead                              <missing documentation>
#   --Db.StateDbDisableCompression                               <missing documentation>
#   --Db.StateDbMaxBytesPerSec                                   <missing documentation>
#   --Db.StateDbMaxOpenFiles                                     <missing documentation>
#   --Db.StateDbUseDirectIoForFlushAndCompactions                <missing documentation>
#   --Db.StateDbUseDirectReads                                   <missing documentation>
#   --Db.StateDbWriteBufferNumber                                <missing documentation>
#   --Db.StateDbWriteBufferSize                                  <missing documentation>
#   --Db.StatsDumpPeriodSec                                      <missing documentation>
#   --Db.UseDirectIoForFlushAndCompactions                       <missing documentation>
#   --Db.UseDirectReads                                          <missing documentation>
#   --Db.WitnessCompactionReadAhead                              <missing documentation>
#   --Db.WitnessDbAdditionalRocksDbOptions                       <missing documentation>
#   --Db.WitnessDbBlockCacheSize                                 <missing documentation>
#   --Db.WitnessDbBlockSize                                      <missing documentation>
#   --Db.WitnessDbCacheIndexAndFilterBlocks                      <missing documentation>
#   --Db.WitnessDbMaxBytesPerSec                                 <missing documentation>
#   --Db.WitnessDbMaxOpenFiles                                   <missing documentation>
#   --Db.WitnessDbWriteBufferNumber                              <missing documentation>
#   --Db.WitnessDbWriteBufferSize                                <missing documentation>
#   --Db.WitnessUseDirectIoForFlushAndCompactions                <missing documentation>
#   --Db.WitnessUseDirectReads                                   <missing documentation>
#   --Db.WriteAheadLogSync                                       <missing documentation>
#   --Db.WriteBufferNumber                                       <missing documentation>
#   --Db.WriteBufferSize                                         <missing documentation>
#   --Discovery.BootnodePongTimeout                               (DEFAULT: 100000)
#   --Discovery.Bootnodes                                        <missing documentation>
#   --Discovery.BucketSize                                        (DEFAULT: 16)
#   --Discovery.Concurrency                                       (DEFAULT: 3)
#   --Discovery.DiscoveryInterval                                 (DEFAULT: 30000)
#   --Discovery.DiscoveryNewCycleWaitTime                         (DEFAULT: 50)
#   --Discovery.DiscoveryPersistenceInterval                      (DEFAULT: 180000)
#   --Discovery.DropFullBucketNodeProbability                     (DEFAULT: 0.05)
#   --Discovery.EvictionCheckInterval                             (DEFAULT: 75)
#   --Discovery.MaxDiscoveryRounds                                (DEFAULT: 8)
#   --Discovery.MaxNodeLifecycleManagersCount                     (DEFAULT: 8000)
#   --Discovery.NodeLifecycleManagersCleanupCount                 (DEFAULT: 4000)
#   --Discovery.PingRetryCount                                    (DEFAULT: 3)
#   --Discovery.PongTimeout                                       (DEFAULT: 15000)
#   --Discovery.SendNodeTimeout                                   (DEFAULT: 500)
#   --Discovery.UdpChannelCloseTimeout                            (DEFAULT: 5000)
#   --EthStats.Contact                                           Node owner contact details displayed on the ethstats page. (DEFAULT: hello@nethermind.io)
#   --EthStats.Enabled                                           If 'true' then EthStats publishing gets enabled. (DEFAULT: false)
#   --EthStats.Name                                              Node name displayed on the given ethstats server. (DEFAULT: Nethermind)
#   --EthStats.Secret                                            Password for publishing to a given ethstats server. (DEFAULT: secret)
#   --EthStats.Server                                            EthStats server wss://hostname:port/api/ (DEFAULT: ws://localhost:3000/api)
#   --HealthChecks.Enabled                                       If 'true' then Health Check endpoints is enabled at /health (DEFAULT: false)
#   --HealthChecks.LowStorageCheckAwaitOnStartup                 Free disk space check on startup will pause node initalization until enough space is available. (DEFAULT: false)
#   --HealthChecks.LowStorageSpaceShutdownThreshold              Percentage of available disk space below which node will shutdown. Zero to disable. (DEFAULT: 1)
#   --HealthChecks.LowStorageSpaceWarningThreshold               Percentage of available disk space below which a warning will be displayed. Zero to disable. (DEFAULT: 5)
#   --HealthChecks.MaxIntervalClRequestTime                      Max request interval in which we assume that CL works in a healthy way (DEFAULT: 300)
#   --HealthChecks.MaxIntervalWithoutProcessedBlock              Max interval in seconds in which we assume that node processing blocks in a healthy way (DEFAULT: null)
#   --HealthChecks.MaxIntervalWithoutProducedBlock               Max interval in seconds in which we assume that node producing blocks in a healthy way (DEFAULT: null)
#   --HealthChecks.PollingInterval                               Configures the UI to poll for healthchecks updates (in seconds) (DEFAULT: 5)
#   --HealthChecks.Slug                                          The URL slug on which Healthchecks service will be exposed (DEFAULT: /health)
#   --HealthChecks.UIEnabled                                     If 'true' then HealthChecks UI will be avaiable at /healthchecks-ui (DEFAULT: false)
#   --HealthChecks.WebhooksEnabled                               If 'true' then Webhooks can be configured (DEFAULT: false)
#   --HealthChecks.WebhooksPayload                               Payload is the json payload that will be send on Failure and must be escaped. (DEFAULT: {"attachments":[{"color":"#FFCC00","pretext":"Health Check Status :warning:","fields":[{"title":"Details","value":"More details available at `/healthchecks-ui`","short":false},{"title":"Description","value":"[[DESCRIPTIONS]]","short":false}]}]})
#   --HealthChecks.WebhooksRestorePayload                        RestorePayload is the json payload that will be send on Recovery and must be escaped. (DEFAULT: {"attachments":[{"color":"#36a64f","pretext":"Health Check Status :+1:","fields":[{"title":"Details","value":"`More details available at /healthchecks-ui`","short":false},{"title":"description","value":"The HealthCheck `[[LIVENESS]]` is recovered. All is up and running","short":false}]}]})
#   --HealthChecks.WebhooksUri                                   The Webhooks endpoint e.g. Slack WebHooks (DEFAULT: null)
#   --Hive.BlocksDir                                             Path to a directory with additional blocks. (DEFAULT: "/blocks")
#   --Hive.ChainFile                                             Path to a file with a test chain definition. (DEFAULT: "/chain.rlp")
#   --Hive.Enabled                                               Enabling hive for debugging purpose (DEFAULT: false)
#   --Hive.GenesisFilePath                                       Path to genesis block. (DEFAULT: "/genesis.json")
#   --Hive.KeysDir                                               Path to a test key store directory. (DEFAULT: "/keys")
#   --Init.AutoDump                                              Auto dump on bad blocks for diagnostics, Possible values [None, Receipts, Parity, Geth, All] (DEFAULT: Receipts)
#   --Init.BaseDbPath                                            Base directory path for all the nethermind databases. (DEFAULT: "db")
#   --Init.ChainSpecPath                                         Path to the chain definition file (Parity chainspec or Geth genesis file). (DEFAULT: chainspec/foundation.json)
#   --Init.DiagnosticMode                                        Diagnostics modes (DEFAULT: None)
#   --Init.DiscoveryEnabled                                      If 'false' then the node does not try to find nodes beyond the bootnodes configured. (DEFAULT: true)
#   --Init.EnableUnsecuredDevWallet                              If 'true' then it enables the wallet / key store in the application. (DEFAULT: false)
#   --Init.GenesisHash                                           Hash of the genesis block - if the default null value is left then the genesis block validity will not be checked which is useful for ad hoc test/private networks. (DEFAULT: null)
#   --Init.HiveChainSpecPath                                     Path to the chain definition file created by Hive for test purpouse (DEFAULT: chainspec/test.json)
#   --Init.IsMining                                              If 'true' then the node will try to seal/mine new blocks (DEFAULT: false)
#   --Init.KeepDevWalletInMemory                                 If 'true' then any accounts created will be only valid during the session and deleted when application closes. (DEFAULT: false)
#   --Init.KzgSetupPath                                          Kzg trusted setup file path (DEFAULT: null)
#   --Init.LogDirectory                                          In case of null, the path is set to [applicationDirectiory]\logs (DEFAULT: logs)
#   --Init.LogFileName                                           Name of the log file generated (useful when launching multiple networks with the same log folder). (DEFAULT: "log.txt")
#   --Init.LogRules                                              Overrides for default logs in format LogPath:LogLevel;* (DEFAULT: null)
#   --Init.MemoryHint                                            A hint for the max memory that will allow us to configure the DB and Netty memory allocations. (DEFAULT: null)
#   --Init.PeerManagerEnabled                                    If 'false' then the node does not connect to newly discovered peers.. (DEFAULT: true)
#   --Init.ProcessingEnabled                                     If 'false' then the node does not download/process new blocks.. (DEFAULT: true)
#   --Init.ReceiptsMigration                                     Moved to ReceiptConfig. (DEFAULT: false)
#   --Init.RpcDbUrl                                              Url for remote node that will be used as DB source when 'DiagnosticMode' is set to'RpcDb' (DEFAULT: )
#   --Init.StaticNodesPath                                       Path to the file with a list of static nodes. (DEFAULT: "Data/static-nodes.json")
#   --Init.StoreReceipts                                         Moved to ReceiptConfig. (DEFAULT: true)
#   --Init.WebSocketsEnabled                                     Defines whether the WebSockets service is enabled on node startup at the 'HttpPort' - e.g. ws://localhost:8545/ws/json-rpc (DEFAULT: true)
#   --JsonRpc.AdditionalRpcUrls                                  Defines additional RPC urls to listen on. Example url format: http://localhost:8550|http;wss|engine;eth;net;subscribe (DEFAULT: [])
#   --JsonRpc.BufferResponses                                    Buffer responses before sending them to client. This allows to set Content-Length in response instead of using Transfer-Encoding: chunked. This may degrade performance on big responses. Max buffered response size is 2GB, chunked responses can be bigger. (DEFAULT: false)
#   --JsonRpc.CallsFilterFilePath                                A path to a file that contains a list of new-line separated approved JSON RPC calls (DEFAULT: Data/jsonrpc.filter)
#   --JsonRpc.Enabled                                            Defines whether the JSON RPC service is enabled on node startup. Configure host and port if default values do not work for you. (DEFAULT: false)
#   --JsonRpc.EnabledModules                                     Defines which RPC modules should be enabled. Built in modules are: Admin, Clique, Consensus, Db, Debug, Deposit, Erc20, Eth, Evm, Health Mev, NdmConsumer, NdmProvider, Net, Nft, Parity, Personal, Proof, Subscribe, Trace, TxPool, Vault, Web3. (DEFAULT: [Eth, Subscribe, Trace, TxPool, Web3, Personal, Proof, Net, Parity, Health, Rpc])
#   --JsonRpc.EngineEnabledModules                               Defines which RPC modules should be enabled Execution Engine port. Built in modules are: Admin, Clique, Consensus, Db, Debug, Deposit, Erc20, Eth, Evm, Health Mev, NdmConsumer, NdmProvider, Net, Nft, Parity, Personal, Proof, Subscribe, Trace, TxPool, Vault, Web3. (DEFAULT: [Net, Eth, Subscribe, Web3])
#   --JsonRpc.EngineHost                                         Host for Execution Engine calls. Ensure the firewall is configured when enabling JSON RPC. If it does not work with 127.0.0.1 try something like 10.0.0.4 or 192.168.0.1 (DEFAULT: "127.0.0.1")
#   --JsonRpc.EnginePort                                         Port for Execution Engine calls. Ensure the firewall is configured when enabling JSON RPC. (DEFAULT: null)
#   --JsonRpc.EthModuleConcurrentInstances                       Number of concurrent instances for non-sharable calls (eth_call, eth_estimateGas, eth_getLogs, eth_newFilter, eth_newBlockFilter, eth_newPendingTransactionFilter, eth_uninstallFilter). This will limit load on the node CPU and IO to reasonable levels. If this limit is exceeded on Http calls 503 Service Unavailable will be returned along with Json RPC error. Defaults to number of logical processes. (DEFAULT: )
#   --JsonRpc.GasCap                                             Gas limit for eth_call and eth_estimateGas (DEFAULT: 100000000)
#   --JsonRpc.Host                                               Host for JSON RPC calls. Ensure the firewall is configured when enabling JSON RPC. If it does not work with 127.0.0.1 try something like 10.0.0.4 or 192.168.0.1 (DEFAULT: "127.0.0.1")
#   --JsonRpc.IpcUnixDomainSocketPath                            The path to connect a unix domain socket over. (DEFAULT: )
#   --JsonRpc.JwtSecretFile                                      Path to file with hex encoded secret for jwt authentication (DEFAULT: keystore/jwt-secret)
#   --JsonRpc.MaxBatchResponseBodySize                           Max response body size when using batch requests, subsequent requests are trimmed (DEFAULT: 30000000)
#   --JsonRpc.MaxBatchSize                                       Limit batch size for batched json rpc call (DEFAULT: 1024)
#   --JsonRpc.MaxLoggedRequestParametersCharacters               Limits the Maximum characters printing to log for parameters of any Json RPC service request (DEFAULT: null)
#   --JsonRpc.MaxRequestBodySize                                 Max HTTP request body size (DEFAULT: 30000000)
#   --JsonRpc.MethodsLoggingFiltering                            Defines method names of Json RPC service requests to NOT log. Example: {"eth_blockNumber"} will not log "eth_blockNumber" requests. (DEFAULT: [engine_newPayloadV1, engine_newPayloadV2, engine_newPayloadV3, engine_forkchoiceUpdatedV1, engine_forkchoiceUpdatedV2])
#   --JsonRpc.Port                                               Port number for JSON RPC calls. Ensure the firewall is configured when enabling JSON RPC. (DEFAULT: 8545)
#   --JsonRpc.ReportIntervalSeconds                              Interval between the JSON RPC stats report log (DEFAULT: 300)
#   --JsonRpc.RequestQueueLimit                                  The queued request limit for calls above the max concurrency amount for (eth_call, eth_estimateGas, eth_getLogs, eth_newFilter, eth_newBlockFilter, eth_newPendingTransactionFilter, eth_uninstallFilter).  If value is set to 0 limit won't be applied. (DEFAULT: 500)
#   --JsonRpc.RpcRecorderBaseFilePath                            Base file path for diagnostic JSON RPC recorder. (DEFAULT: "logs/rpc.{counter}.txt")
#   --JsonRpc.RpcRecorderState                                   Defines whether the JSON RPC diagnostic recording is enabled on node startup. Do not enable unless you are a DEV diagnosing issues with JSON RPC. Possible values: None/Request/Response/All. (DEFAULT: None)
#   --JsonRpc.Timeout                                            JSON RPC' timeout value given in milliseconds. (DEFAULT: 20000)
#   --JsonRpc.UnsecureDevNoRpcAuthentication                     It shouldn't be set to true for production nodes. If set to true all modules can work without RPC authentication. (DEFAULT: false)
#   --JsonRpc.WebSocketsPort                                     Port number for JSON RPC web sockets calls. By default same port is used as regular JSON RPC. Ensure the firewall is configured when enabling JSON RPC. (DEFAULT: 8545)
#   --KeyStore.BlockAuthorAccount                                Account to be used by the block author / coinbase, to be loaded from keystore (DEFAULT: )
#   --KeyStore.Cipher                                            See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: aes-128-ctr)
#   --KeyStore.EnodeAccount                                      Account to be used by the node for network communication (enode), to be loaded from keystore. If neither this nor EnodeKeyFile is specified, the key for network communication will be autogenerated in 'node.key.plain' file. (DEFAULT: )
#   --KeyStore.EnodeKeyFile                                      Path to key file to be used by the node for network communication (enode). If neither this nor EnodeAccount is specified, the key for network communication will be autogenerated in 'node.key.plain' file. If the file does not exist it will be generated. (DEFAULT: )
#   --KeyStore.IVSize                                            See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: 16)
#   --KeyStore.Kdf                                               See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: scrypt)
#   --KeyStore.KdfparamsDklen                                    See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: 32)
#   --KeyStore.KdfparamsN                                        See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: 262144)
#   --KeyStore.KdfparamsP                                        See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: 1)
#   --KeyStore.KdfparamsR                                        See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: 8)
#   --KeyStore.KdfparamsSaltLen                                  See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: 32)
#   --KeyStore.KeyStoreDirectory                                 Directory to store keys in. (DEFAULT: keystore)
#   --KeyStore.KeyStoreEncoding                                  See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: UTF-8)
#   --KeyStore.PasswordFiles                                     Password files storing passwords to unlock the accounts from the UnlockAccounts configuration item (DEFAULT: [])
#   --KeyStore.Passwords                                         Passwords to use to unlock accounts from the UnlockAccounts configuration item. Only used when no PasswordFiles provided. (DEFAULT: [])
#   --KeyStore.SymmetricEncrypterBlockSize                       See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: 128)
#   --KeyStore.SymmetricEncrypterKeySize                         See https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition (DEFAULT: 128)
#   --KeyStore.TestNodeKey                                       Plain private key to be used in test scenarios (DEFAULT: )
#   --KeyStore.UnlockAccounts                                    Accounts to unlock on startup using provided PasswordFiles and Passwords (DEFAULT: [])
#   --Merge.BuilderRelayUrl                                      URL to Builder Relay. If set when building blocks nethermind will send them to the relay. (DEFAULT: null)
#   --Merge.CollectionsPerDecommit                               Requests the GC to release process memory back to OS. Accept values `-1` which disables it, `0` which releases every time, and any positive integer which does it after that many EngineApi calls. (DEFAULT: 75)
#   --Merge.CompactMemory                                        Reduces process used memory. Accept values `No` which disables it, `Yes` which compacts normal heaps, `Full` compacts large object heap too (only when SweepMemory is set to `Gen2`). (DEFAULT: Yes)
#   --Merge.Enabled                                              Defines whether the Merge plugin is enabled bundles are allowed. (DEFAULT: true)
#   --Merge.FinalTotalDifficulty                                 Final total difficulty is total difficulty of the last PoW block. FinalTotalDifficulty >= TerminalTotalDifficulty. (DEFAULT: null)
#   --Merge.NewPayloadTimeout                                    Maximum time in seconds for NewPayload request to be executed. (DEFAULT: 7)
#   --Merge.PrioritizeBlockLatency                               Reduces block EngineApi latency by disabling Garbage Collection during EngineApi calls. (DEFAULT: true)
#   --Merge.SecondsPerSlot                                       Deprecated since v1.14.7. Please use Blocks.SecondsPerSlot. Seconds per slot. (DEFAULT: 12)
#   --Merge.SweepMemory                                          Reduces memory usage by forcing Garbage Collection between EngineApi calls. Accept values `NoGc` (-1), Gen0 (0), Gen1 (1), Gen2 (2). (DEFAULT: Gen1)
#   --Merge.TerminalBlockHash                                    Terminal PoW block hash used for transition process. (DEFAULT: null)
#   --Merge.TerminalBlockNumber                                  Terminal PoW block number used for transition process. (DEFAULT: )
#   --Merge.TerminalTotalDifficulty                              Terminal total difficulty used for transition process. (DEFAULT: null)
#   --Metrics.CountersEnabled                                    If 'true',the node publishes metrics using .NET diagnostics that can be collected with dotnet-counters. (DEFAULT: false)
#   --Metrics.EnableDbSizeMetrics                                If set, will push db size metrics (DEFAULT: true)
#   --Metrics.Enabled                                            If 'true',the node publishes various metrics to Prometheus Pushgateway at given interval. (DEFAULT: false)
#   --Metrics.ExposePort                                         If set, the node exposes Prometheus metrics on the given port. (DEFAULT: null)
#   --Metrics.IntervalSeconds                                    Defines how often metrics are pushed to Prometheus (DEFAULT: 5)
#   --Metrics.NodeName                                           Name displayed in the Grafana dashboard (DEFAULT: "Nethermind")
#   --Metrics.PushGatewayUrl                                     Prometheus Pushgateway URL. (DEFAULT: )
#   --Mev.BundleHorizon                                          Defines how long MEV bundles will be kept in memory by clients (DEFAULT: 3600)
#   --Mev.BundlePoolSize                                         Defines the maximum number of MEV bundles that can be kept in memory by clients (DEFAULT: 200)
#   --Mev.Enabled                                                Defines whether the MEV bundles are allowed. (DEFAULT: false)
#   --Mev.MaxMergedBundles                                       Defines the maximum number of MEV bundles to be included within a single block (DEFAULT: 1)
#   --Mev.TrustedRelays                                          Defines the list of trusted relay addresses to receive megabundles from as a comma separated string (DEFAULT: )
#   --Mining.Enabled                                             Defines whether the blocks should be produced. (DEFAULT: false)
#   --Mining.ExtraData                                           Deprecated since v1.14.6. Please use Blocks.ExtraDataValues you set here are forwarded to it. Conflicting values will cause Exceptions. Block header extra data. 32-bytes shall be extra data max length. (DEFAULT: Nethermind)
#   --Mining.MinGasPrice                                         Deprecated since v1.14.6. Please use Blocks.MinGasPrice Values you set here are forwarded to it. Conflicting values will cause Exceptions. Minimum gas premium for transactions accepted by the block producer. Before EIP1559: Minimum gas price for transactions accepted by the block producer. (DEFAULT: 1)
#   --Mining.RandomizedBlocks                                    Deprecated since v1.14.6. Please use Blocks.RandomizedBlocks Values you set here are forwarded to it. Conflicting values will cause Exceptions. Only used in NethDev. Setting this to true will change the difficulty of the block randomly within the constraints. (DEFAULT: false)
#   --Mining.TargetBlockGasLimit                                 Deprecated since v1.14.6. Please use Blocks.TargetBlockGasLimit. Values you set here are forwarded to it. Conflicting values will cause Exceptions. Block gas limit that the block producer should try to reach in the fastest possible way based on protocol rules. NULL value means that the miner should follow other miners. (DEFAULT: null)
#   --Network.ActivePeersMaxCount                                [OBSOLETE](Use MaxActivePeers instead) Max number of connected peers. (DEFAULT: 50)
#   --Network.Bootnodes                                          Bootnodes (DEFAULT: )
#   --Network.ClientIdMatcher                                    [TECHNICAL] Only allow peer with clientId matching this regex. Useful for testing. eg: 'besu' to only connect to BeSU (DEFAULT: )
#   --Network.ConnectTimeoutMs                                   [TECHNICAL] Outgoing connection timeout in ms. Default is 2 seconds. (DEFAULT: 2000)
#   --Network.DiagTracerEnabled                                  Enabled very verbose diag network tracing files for DEV purposes (Nethermind specific) (DEFAULT: false)
#   --Network.DisableDiscV4DnsFeeder                             [TECHNICAL] Disable feeding ENR DNS records to discv4 table (DEFAULT: false)
#   --Network.DiscoveryDns                                       Use tree is available through a DNS name. Keep it empty for the default of {chainName}.ethdisco.net (DEFAULT: null)
#   --Network.DiscoveryPort                                      UDP port number for incoming discovery connections. Keep same as TCP/IP port because using different values has never been tested. (DEFAULT: 30303)
#   --Network.EnableUPnP                                         Enable automatic port forwarding via UPnP (DEFAULT: false)
#   --Network.ExternalIp                                         Use only if your node cannot resolve external IP automatically. (DEFAULT: null)
#   --Network.LocalIp                                            Use only if your node cannot resolve local IP automatically. (DEFAULT: null)
#   --Network.MaxActivePeers                                     Same as ActivePeersMaxCount. (DEFAULT: 50)
#   --Network.MaxNettyArenaCount                                 [TECHNICAL] Defines maximum netty arena count. Increasing this on high core machine without increasing memory budget may reduce chunk size so much that it causes significant netty huge allocation. (DEFAULT: 8)
#   --Network.MaxOutgoingConnectPerSec                           [TECHNICAL] Max number of new outgoing connections per second. Default is 20. (DEFAULT: 20)
#   --Network.NettyArenaOrder                                    [TECHNICAL] Defines the size of a netty arena order. Default depends on memory hint. (DEFAULT: -1)
#   --Network.NumConcurrentOutgoingConnects                      [TECHNICAL] Number of concurrent outgoing connections. Reduce this if your ISP throttles from having open too many connections. Default is 0 which means same as processor count. (DEFAULT: 0)
#   --Network.OnlyStaticPeers                                    If set to 'true' then no connections will be made to non-static peers. (DEFAULT: false)
#   --Network.P2PPort                                            TPC/IP port number for incoming P2P connections. (DEFAULT: 30303)
#   --Network.PriorityPeersMaxCount                              Max number of priority peers. Can be overwritten by value from plugin config. (DEFAULT: 0)
#   --Network.ProcessingThreadCount                              [TECHNICAL] Num of thread in final processing of network packet. Set to more than 1 if you have very fast internet. (DEFAULT: 1)
#   --Network.SimulateSendLatencyMs                              [TECHNICAL] Introduce a fixed latency for all p2p message send. Useful for testing higher latency network or simulate slower network for testing purpose. (DEFAULT: 0)
#   --Network.StaticPeers                                        List of nodes for which we will keep the connection on. Static nodes are not counted to the max number of nodes limit. (DEFAULT: null)
#   --Plugin.PluginOrder                                         Order of plugin initialization (DEFAULT: [Clique, Aura, Ethash, AuRaMerge, Merge, MEV, HealthChecks, Hive])
#   --Pruning.AvailableSpaceCheckEnabled                         Enables available disk space check. (DEFAULT: true)
#   --Pruning.CacheMb                                            'Memory' pruning: Pruning cache size in MB (amount if historical nodes data to store in cache - the bigger the cache the bigger the disk space savings). (DEFAULT: 1024)
#   --Pruning.Enabled                                            Enables in-memory pruning. Obsolete, use Mode instead. (DEFAULT: true)
#   --Pruning.FullPruningCompletionBehavior                      Determines what to do after Nethermind completes a full prune. 'None': does not take any special action. 'ShutdownOnSuccess': shuts Nethermind down if the full prune succeeded. 'AlwaysShutdown': shuts Nethermind down once the prune completes, whether it succeeded or failed. (DEFAULT: None)
#   --Pruning.FullPruningDisableLowPriorityWrites                Full pruning uses low priority writes to prevent blocking block processing. If not needed, set this to true for faster full pruning. (DEFAULT: false)
#   --Pruning.FullPruningMaxDegreeOfParallelism                  'Full' pruning: Defines how many parallel tasks and potentially used threads can be created by full pruning. -1 - number of logical processors, 0 - 25% of logical processors, 1 - full pruning will run on single thread. Recommended value depends on the type of the node. If the node needs to be responsive (its RPC or Validator node) then recommended value is the default value or below is recommended. If the node doesn't have much other responsibilities but needs to be reliably be able to follow the chain without any delays and produce live logs - the default value or above is recommended. If the node doesn't have to be responsive, has very fast I/O (like NVME) and the shortest pruning time is to be achieved, this can be set to the number of logical processors (-1). (DEFAULT: 0)
#   --Pruning.FullPruningMemoryBudgetMb                          Set the memory budget used for the trie visit. Increasing this significantly reduces read iops requirement at expense of RAM. Default depend on network. Set to 0 to disable. (DEFAULT: 4000)
#   --Pruning.FullPruningMinimumDelayHours                       In order to not exhaust disk writes, there is a minimum delay between allowed full pruning operations. (DEFAULT: 240)
#   --Pruning.FullPruningThresholdMb                             'Full' pruning: Defines threshold in MB to trigger full pruning, depends on 'Mode' and 'FullPruningTrigger'. (DEFAULT: 256000)
#   --Pruning.FullPruningTrigger                                 'Full' pruning: Defines trigger for full pruning, manuel trigger is always supported via admin_prune RPC call. Either size of StateDB or free space left on Volume where StateDB is located can be configured as auto triggers. Possible values: 'Manual', 'StateDbSize', 'VolumeFreeSpace'. (DEFAULT: Manual)
#   --Pruning.Mode                                               Sets pruning mode. Possible values: 'None', 'Memory', 'Full', 'Hybrid'. (DEFAULT: Hybrid)
#   --Pruning.PersistenceInterval                                'Memory' pruning: Defines how often blocks will be persisted even if not required by cache memory usage (the bigger the value the bigger the disk space savings) (DEFAULT: 8192)
#   --Receipt.CompactReceiptStore                                If set to 'true' then reduce receipt db size at expense of rpc performance. (DEFAULT: true)
#   --Receipt.CompactTxIndex                                     If set to 'true' then reduce receipt tx index db size at expense of rpc performance. (DEFAULT: true)
#   --Receipt.ForceReceiptsMigration                             Force receipt recovery if its not able to detect it. (DEFAULT: false)
#   --Receipt.MaxBlockDepth                                      Max num of block per eth_getLogs request. (DEFAULT: 10000)
#   --Receipt.ReceiptsMigration                                  If set to 'true' then receipts db will be migrated to new schema. (DEFAULT: false)
#   --Receipt.ReceiptsMigrationDegreeOfParallelism               [TECHNICAL] Specify degree of parallelism during receipt migration. (DEFAULT: 0)
#   --Receipt.StoreReceipts                                      If set to 'false' then transaction receipts will not be stored in the database after a new block is processed. This setting is independent from downloading receipts in fast sync mode. (DEFAULT: true)
#   --Receipt.TxLookupLimit                                      Number of recent blocks to maintain transaction index. 0 to never remove tx index. -1 to never index. (DEFAULT: 2350000)
#   --Seq.ApiKey                                                 API key used for log events ingestion to Seq instance (DEFAULT: )
#   --Seq.MinLevel                                               Minimal level of log events which will be sent to Seq instance. (DEFAULT: Off)
#   --Seq.ServerUrl                                              Seq instance URL. (DEFAULT: "http://localhost:5341)
#   --Sync.AncientBodiesBarrier                                  [EXPERIMENTAL] Defines the earliest body downloaded in fast sync when DownloadBodiesInFastSync is enabled. Actual values used will be Math.Max(1, Math.Min(PivotNumber, AncientBodiesBarrier)) (DEFAULT: 0)
#   --Sync.AncientReceiptsBarrier                                [EXPERIMENTAL] Defines the earliest receipts downloaded in fast sync when DownloadReceiptsInFastSync is enabled. Actual value used will be Math.Max(1, Math.Min(PivotNumber, Math.Max(AncientBodiesBarrier, AncientReceiptsBarrier))) (DEFAULT: 0)
#   --Sync.BlocksDbTuneDbMode                                    [EXPERIMENTAL] Optimize db for write during sync just for blocks db. Useful for turning on blobs file. (DEFAULT: EnableBlobFiles)
#   --Sync.DownloadBodiesInFastSync                              If set to 'true' then the block bodies will be downloaded in the Fast Sync mode. (DEFAULT: true)
#   --Sync.DownloadHeadersInFastSync                             If set to 'false' then fast sync will only download recent blocks. (DEFAULT: true)
#   --Sync.DownloadReceiptsInFastSync                            If set to 'true' then the receipts will be downloaded in the Fast Sync mode. This will slow down the process by a few hours but will allow you to interact with dApps that execute extensive historical logs searches (like Maker CDPs). (DEFAULT: true)
#   --Sync.ExitOnSynced                                          Exit Nethermind once sync is finished (DEFAULT: false)
#   --Sync.ExitOnSyncedWaitTimeSec                               Specify wait time after sync finished. (DEFAULT: 60)
#   --Sync.FastBlocks                                            If set to 'true' then in the Fast Sync mode blocks will be first downloaded from the provided PivotNumber downwards. This allows for parallelization of requests with many sync peers and with no need to worry about syncing a valid branch (syncing downwards to 0). You need to enter the pivot block number, hash and total difficulty from a trusted source (you can use etherscan and confirm with other sources if you wan to change it). (DEFAULT: false)
#   --Sync.FastSync                                              If set to 'true' then the Fast Sync (eth/63) synchronization algorithm will be used. (DEFAULT: false)
#   --Sync.FastSyncCatchUpHeightDelta                            Relevant only if 'FastSync' is 'true'. If set to a value, then it will set a minimum height threshold limit up to which FullSync, if already on, will stay on when chain will be behind network. If this limit will be exceeded, it will switch back to FastSync. In normal usage we do not recommend setting this to less than 32 as this can cause issues with chain reorgs. Please note that last 2 blocks will always be processed in FullSync, so setting it to less than 2 will have no effect. (DEFAULT: 8192)
#   --Sync.FixReceipts                                           [ONLY FOR MISSING RECEIPTS ISSUE] Turns on receipts validation that checks for ones that might be missing due to previous bug. It downloads them from network if needed.If used please check that PivotNumber is same as original used when syncing the node as its used as a cut-off point. (DEFAULT: false)
#   --Sync.FixTotalDifficulty                                    [ONLY TO FIX INCORRECT TOTAL DIFFICULTY ISSUE] Recalculates total difficulty starting from FixTotalDifficultyStartingBlock to FixTotalDifficultyLastBlock. (DEFAULT: false)
#   --Sync.FixTotalDifficultyLastBlock                           [ONLY TO FIX INCORRECT TOTAL DIFFICULTY ISSUE] Last block which total difficulty will be recalculated. If set to null equals to best known block (DEFAULT: null)
#   --Sync.FixTotalDifficultyStartingBlock                       [ONLY TO FIX INCORRECT TOTAL DIFFICULTY ISSUE] First block which total difficulty will be recalculated. (DEFAULT: 1)
#   --Sync.MaxAttemptsToUpdatePivot                              Max number of attempts (seconds) to update pivot block basing on Forkchoice message from Consensus Layer. Only for PoS chains. Infinite by default. (DEFAULT: 2147483647)
#   --Sync.MaxProcessingThreads                                  [TECHNICAL] Specify max num of thread used for processing. Default is same as logical core count. (DEFAULT: 0)
#   --Sync.NetworkingEnabled                                     If 'false' then the node does not connect to peers. (DEFAULT: true)
#   --Sync.NonValidatorNode                                      [EXPERIMENTAL] Only for non validator nodes! If set to true, DownloadReceiptsInFastSync and/or DownloadBodiesInFastSync can be set to false. (DEFAULT: false)
#   --Sync.PivotHash                                             Hash of the pivot block for the Fast Blocks sync. (DEFAULT: null)
#   --Sync.PivotNumber                                           Number of the pivot block for the Fast Blocks sync. (DEFAULT: 0)
#   --Sync.PivotTotalDifficulty                                  Total Difficulty of the pivot block for the Fast Blocks sync (not - this is total difficulty and not difficulty). (DEFAULT: null)
#   --Sync.SnapSync                                              Enables SNAP sync protocol. (DEFAULT: false)
#   --Sync.SnapSyncAccountRangePartitionCount                    Number of account range partition to create. Increase snap sync request concurrency. Value must be between 1 to 256 (inclusive). (DEFAULT: 8)
#   --Sync.StrictMode                                            Disable some optimization and run a more extensive sync. Useful for broken sync state but normally not needed (DEFAULT: false)
#   --Sync.SynchronizationEnabled                                If 'false' then the node does not download/process new blocks. (DEFAULT: true)
#   --Sync.TuneDbMode                                            [EXPERIMENTAL] Optimize db for write during sync. Significantly reduce total writes written and some sync time if you are not network limited. (DEFAULT: HeavyWrite)
#   --Sync.UseGethLimitsInFastBlocks                             If set to 'true' then in the Fast Blocks mode Nethermind generates smaller requests to avoid Geth from disconnecting. On the Geth heavy networks (mainnet) it is desired while on Parity or Nethermind heavy networks (Goerli, AuRa) it slows down the sync by a factor of ~4 (DEFAULT: true)
#   --Sync.WitnessProtocolEnabled                                Enables witness protocol. (DEFAULT: false)
#   --TraceStore.BlocksToKeep                                    Defines how many blocks counting from head are kept in the TraceStore, if '0' all traces of processed blocks will be kept. (DEFAULT: 10000)
#   --TraceStore.DeserializationParallelization                  Maximum parallelization when deserializing requests for trace_filter. 0 defaults to logical cores, set to something low if you experience too big resource usage. (DEFAULT: 0)
#   --TraceStore.Enabled                                         Defines whether the TraceStore plugin is enabled, if 'true' traces will come from DB if possible. (DEFAULT: false)
#   --TraceStore.MaxDepth                                        Depth to deserialize traces. (DEFAULT: 1024)
#   --TraceStore.TraceTypes                                      Defines what kind of traces are saved and kept in TraceStore. Available options are: Trace, Rewards, VmTrace, StateDiff or just All. (DEFAULT: Trace, Rewards)
#   --TraceStore.VerifySerialized                                Verifies all the serialized elements. (DEFAULT: false)
#   --TxPool.GasLimit                                            Max transaction gas allowed. (DEFAULT: null)
#   --TxPool.HashCacheSize                                       Max number of cached hashes of already known transactions.It is set automatically by the memory hint. (DEFAULT: 524288)
#   --TxPool.PeerNotificationThreshold                           Defines average percent of tx hashes from persistent broadcast send to peer together with hashes of last added txs. Set this value to 100 if you want to broadcast all transactions. (DEFAULT: 5)
#   --TxPool.ReportMinutes                                       Minutes between reporting on current state of tx pool. (DEFAULT: null)
#   --TxPool.Size                                                Max number of transactions held in mempool (more transactions in mempool mean more memory used (DEFAULT: 2048)
#   --Wallet.DevAccounts                                         Number of auto-generted dev accounts to work with. Dev accounts will have private keys from 00...01 to 00..n (DEFAULT: 10)

# Configurable Environment Variables:
# NETHERMIND_CLI_SWITCH_LOCAL - Defines host value for CLI function "switchLocal". (DEFAULT: http://localhost)
# NETHERMIND_CORS_ORIGINS - Defines CORS origins for JSON RPC. (DEFAULT: *)
# NETHERMIND_ENODE_IPADDRESS - Sets the external IP for the node. (DEFAULT: )
# NETHERMIND_HIVE_ENABLED - Enables Hive plugin used for executing Hive Ethereum Tests. (DEFAULT: false)
# NETHERMIND_MONITORING_GROUP - Sets the default group name for metrics monitoring. (DEFAULT: )
# NETHERMIND_MONITORING_JOB - Sets the job name for metrics monitoring. (DEFAULT: )
# NETHERMIND_URL - Defines default URL for JSON RPC. (DEFAULT: )
