# 🎵 DAO-Governed Radio Station

> A decentralized radio station where members vote on playlists! 🗳️📻

## 📖 Overview

The DAO-Governed Radio Station is a smart contract built on Stacks that allows members to democratically create and vote on radio playlists. Members stake STX to join the DAO, propose playlists, and vote on what music gets played on the station.

## ✨ Features

- 🎪 **DAO Membership**: Stake STX to become a voting member
- 🎼 **Playlist Creation**: Members can create playlists with up to 20 songs
- 🗳️ **Democratic Voting**: Vote for or against proposed playlists
- ⏰ **Time-based Voting**: Voting periods with automatic finalization
- 🏆 **Reputation System**: Earn reputation for approved playlists
- 👑 **Governance**: Owner controls for stake requirements and voting periods

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- STX tokens for staking

### Installation
```bash
git clone https://github.com/your-username/DAO-Governed-Radio-Station
cd DAO-Governed-Radio-Station
clarinet check
```

## 🎯 Usage

### Joining the DAO
```clarity
(contract-call? .DAO-Governed-Radio-Station join-dao)
```
*Requires minimum stake (default: 1,000,000 µSTX)*

### Creating a Playlist 🎵
```clarity
(contract-call? .DAO-Governed-Radio-Station create-playlist 
  "Summer Hits 2024" 
  (list "Song 1" "Song 2" "Song 3"))
```

### Voting on Playlists 🗳️
```clarity
;; Vote FOR a playlist
(contract-call? .DAO-Governed-Radio-Station vote-on-playlist u1 true)

;; Vote AGAINST a playlist  
(contract-call? .DAO-Governed-Radio-Station vote-on-playlist u1 false)
```

### Finalizing Results ✅
```clarity
(contract-call? .DAO-Governed-Radio-Station finalize-playlist u1)
```
*Can only be called after voting period ends*

### Leaving the DAO 👋
```clarity
(contract-call? .DAO-Governed-Radio-Station leave-dao)
```
*Returns your staked STX*

## 📊 Read-Only Functions

### Check Membership Status
```clarity
(contract-call? .DAO-Governed-Radio-Station is-member 'SP1EXAMPLE...)
(contract-call? .DAO-Governed-Radio-Station get-member 'SP1EXAMPLE...)
```

### Get Playlist Details
```clarity
(contract-call? .DAO-Governed-Radio-Station get-playlist u1)
(contract-call? .DAO-Governed-Radio-Station get-total-playlists)
```

### Check Voting Status
```clarity
(contract-call? .DAO-Governed-Radio-Station get-playlist-vote u1 'SP1EXAMPLE...)
```

## ⚙️ Configuration

### Owner Functions (Admin Only)
```clarity
;; Set minimum stake requirement
(contract-call? .DAO-Governed-Radio-Station set-minimum-stake u2000000)

;; Set voting period (in blocks)
(contract-call? .DAO-Governed-Radio-Station set-voting-period u288)

;; Transfer ownership
(contract-call? .DAO-Governed-Radio-Station transfer-ownership 'SP2NEW-OWNER...)
```

## 🔧 Default Settings

- **Minimum Stake**: 1,000,000 µSTX (1 STX)
- **Voting Period**: 144 blocks (~24 hours)
- **Max Songs per Playlist**: 20
- **Reputation Reward**: 10 points per approved playlist

## 🏗️ Contract Structure

### Data Variables
- `contract-owner`: Contract administrator
- `minimum-stake`: Required STX to join DAO  
- `voting-period`: Blocks for voting duration
- `playlist-counter`: Total playlists created

### Maps
- `members`: Member stake, join date, and reputation
- `playlists`: Playlist details, votes, and status
- `playlist-votes`: Individual vote tracking

## 🎨 Playlist Status Flow

1. **Active**: 🟢 Open for voting
2. **Approved**: ✅ More votes for than against
3. **Rejected**: ❌ More votes against than for

## 🔒 Security Features

- Stake-based membership prevents spam
- One vote per member per playlist
- Time-locked voting prevents manipulation  
- Member verification on all operations

## 🧪 Testing

```bash
clarinet test
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License.

---

*Built with ❤️ on Stacks blockchain*
