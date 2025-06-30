#!/bin/bash

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if monero is installed
if ! command -v monero-wallet-cli &> /dev/null; then
    echo -e "${RED}Error: Monero is not installed.${NC}"
    echo "Please install it first using: sudo apt-get install monero"
    exit 1
fi

# Function to display the main menu
show_menu() {
    clear
    echo -e "${GREEN}=== Monero Wallet Menu ===${NC}"
    echo -e "${YELLOW}Wallet Management:${NC}"
    echo -e "${YELLOW}1.${NC} Create New Wallet"
    echo -e "${YELLOW}2.${NC} Open Existing Wallet"
    echo -e "${YELLOW}3.${NC} Restore Wallet from Seed"
    echo -e "\n${YELLOW}Wallet Operations:${NC}"
    echo -e "${YELLOW}4.${NC} Show Wallet Info"
    echo -e "${YELLOW}5.${NC} Show Balance"
    echo -e "${YELLOW}6.${NC} Show All Addresses"
    echo -e "${YELLOW}7.${NC} Create New Subaddress"
    echo -e "${YELLOW}8.${NC} Send XMR"
    echo -e "${YELLOW}9.${NC} Show Transactions"
    echo -e "${YELLOW}10.${NC} Sweep All Funds"
    echo -e "${YELLOW}11.${NC} Show Seed Words"
    echo -e "${YELLOW}12.${NC} Refresh Wallet"
    echo -e "${YELLOW}13.${NC} Check Wallet Status"
    echo -e "\n${YELLOW}Advanced Features:${NC}"
    echo -e "${YELLOW}14.${NC} Integrated Address Operations"
    echo -e "${YELLOW}15.${NC} Payment Verification"
    echo -e "${YELLOW}16.${NC} Transaction Key Management"
    echo -e "${YELLOW}17.${NC} Address Book"
    echo -e "${YELLOW}18.${NC} Wallet Description"
    echo -e "${YELLOW}19.${NC} Make Donation For Monero"
    echo -e "${YELLOW}20.${NC} Show Version"
    echo -e "${YELLOW}0.${NC} Exit"
    echo
    echo -e "${GREEN}Choose an option:${NC}"
}

# Function to show integrated address menu
show_integrated_address_menu() {
    clear
    echo -e "${GREEN}=== Integrated Address Operations ===${NC}"
    echo -e "${YELLOW}1.${NC} Generate Random Integrated Address"
    echo -e "${YELLOW}2.${NC} Generate Integrated Address with Specific Payment ID"
    echo -e "${YELLOW}0.${NC} Back to Main Menu"
    echo
    echo -e "${GREEN}Choose an option:${NC}"
}

# Function to show payment verification menu
show_payment_verification_menu() {
    clear
    echo -e "${GREEN}=== Payment Verification ===${NC}"
    echo -e "${YELLOW}1.${NC} Check Payment by Payment ID"
    echo -e "${YELLOW}2.${NC} Verify Transaction Proof"
    echo -e "${YELLOW}0.${NC} Back to Main Menu"
    echo
    echo -e "${GREEN}Choose an option:${NC}"
}

# Function to show address book menu
show_address_book_menu() {
    clear
    echo -e "${GREEN}=== Address Book Operations ===${NC}"
    echo -e "${YELLOW}1.${NC} Show All Entries"
    echo -e "${YELLOW}2.${NC} Add New Entry"
    echo -e "${YELLOW}3.${NC} Delete Entry"
    echo -e "${YELLOW}0.${NC} Back to Main Menu"
    echo
    echo -e "${GREEN}Choose an option:${NC}"
}

# Function to execute monero-wallet-cli commands
execute_command() {
    echo "$1" | monero-wallet-cli
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

# Function to create new wallet
create_new_wallet() {
    echo -e "${GREEN}Enter new wallet name:${NC}"
    read -r wallet_name
    echo -e "${GREEN}Choose network:${NC}"
    echo "1. Mainnet"
    echo "2. Stagenet"
    echo "3. Testnet"
    read -r network_choice
    
    case $network_choice in
        1)
            network_flag=""
            ;;
        2)
            network_flag="--stagenet"
            ;;
        3)
            network_flag="--testnet"
            ;;
        *)
            echo -e "${RED}Invalid choice. Using mainnet.${NC}"
            network_flag=""
            ;;
    esac
    
    monero-wallet-cli $network_flag --generate-new-wallet "$wallet_name"
}

# Function to open existing wallet
open_existing_wallet() {
    echo -e "${GREEN}Enter wallet file path:${NC}"
    read -r wallet_path
    monero-wallet-cli --wallet-file "$wallet_path"
}

# Function to restore wallet from seed
restore_wallet() {
    echo -e "${GREEN}Enter new wallet name:${NC}"
    read -r wallet_name
    echo -e "${GREEN}Choose network:${NC}"
    echo "1. Mainnet"
    echo "2. Stagenet"
    echo "3. Testnet"
    read -r network_choice
    
    case $network_choice in
        1)
            network_flag=""
            ;;
        2)
            network_flag="--stagenet"
            ;;
        3)
            network_flag="--testnet"
            ;;
        *)
            echo -e "${RED}Invalid choice. Using mainnet.${NC}"
            network_flag=""
            ;;
    esac
    
    monero-wallet-cli $network_flag --restore-deterministic-wallet --generate-new-wallet "$wallet_name"
}

# Main loop
while true; do
    show_menu
    read -r choice

    case $choice in
        1)
            create_new_wallet
            ;;
        2)
            open_existing_wallet
            ;;
        3)
            restore_wallet
            ;;
        4)
            execute_command "wallet_info"
            ;;
        5)
            execute_command "balance"
            ;;
        6)
            execute_command "address all"
            ;;
        7)
            echo -e "${GREEN}Enter label for new subaddress (optional):${NC}"
            read -r label
            if [ -z "$label" ]; then
                execute_command "address new"
            else
                execute_command "address new $label"
            fi
            ;;
        8)
            echo -e "${GREEN}Enter destination address:${NC}"
            read -r address
            echo -e "${GREEN}Enter amount to send:${NC}"
            read -r amount
            execute_command "transfer $address $amount"
            ;;
        9)
            echo -e "${YELLOW}Select transaction type:${NC}"
            echo "1. All"
            echo "2. Incoming"
            echo "3. Outgoing"
            echo "4. Pending"
            echo "5. Failed"
            echo "6. Pool"
            read -r tx_type
            case $tx_type in
                1) execute_command "show_transfers" ;;
                2) execute_command "show_transfers in" ;;
                3) execute_command "show_transfers out" ;;
                4) execute_command "show_transfers pending" ;;
                5) execute_command "show_transfers failed" ;;
                6) execute_command "show_transfers pool" ;;
                *) echo -e "${RED}Invalid option${NC}" ;;
            esac
            ;;
        10)
            echo -e "${GREEN}Enter destination address for sweeping:${NC}"
            read -r sweep_address
            execute_command "sweep_all $sweep_address"
            ;;
        11)
            execute_command "seed"
            ;;
        12)
            execute_command "refresh"
            ;;
        13)
            execute_command "status"
            ;;
        14)
            while true; do
                show_integrated_address_menu
                read -r int_choice
                case $int_choice in
                    1)
                        execute_command "integrated_address"
                        ;;
                    2)
                        echo -e "${GREEN}Enter payment ID:${NC}"
                        read -r payment_id
                        execute_command "integrated_address $payment_id"
                        ;;
                    0)
                        break
                        ;;
                    *)
                        echo -e "${RED}Invalid option${NC}"
                        sleep 2
                        ;;
                esac
            done
            ;;
        15)
            while true; do
                show_payment_verification_menu
                read -r verify_choice
                case $verify_choice in
                    1)
                        echo -e "${GREEN}Enter payment ID:${NC}"
                        read -r payment_id
                        execute_command "payments $payment_id"
                        ;;
                    2)
                        echo -e "${GREEN}Enter transaction ID:${NC}"
                        read -r txid
                        echo -e "${GREEN}Enter transaction key:${NC}"
                        read -r txkey
                        echo -e "${GREEN}Enter recipient address:${NC}"
                        read -r address
                        execute_command "check_tx_key $txid $txkey $address"
                        ;;
                    0)
                        break
                        ;;
                    *)
                        echo -e "${RED}Invalid option${NC}"
                        sleep 2
                        ;;
                esac
            done
            ;;
        16)
            echo -e "${GREEN}Enable transaction key storage? (y/n):${NC}"
            read -r enable_tx_key
            if [[ "$enable_tx_key" == "y" ]]; then
                execute_command "set store-tx-info 1"
                echo -e "${GREEN}Enter transaction ID to get key:${NC}"
                read -r txid
                execute_command "get_tx_key $txid"
            fi
            ;;
        17)
            while true; do
                show_address_book_menu
                read -r book_choice
                case $book_choice in
                    1)
                        execute_command "address_book"
                        ;;
                    2)
                        echo -e "${GREEN}Enter address:${NC}"
                        read -r addr
                        echo -e "${GREEN}Enter description:${NC}"
                        read -r desc
                        execute_command "address_book add $addr $desc"
                        ;;
                    3)
                        echo -e "${GREEN}Enter index to delete:${NC}"
                        read -r index
                        execute_command "address_book delete $index"
                        ;;
                    0)
                        break
                        ;;
                    *)
                        echo -e "${RED}Invalid option${NC}"
                        sleep 2
                        ;;
                esac
            done
            ;;
        18)
            echo -e "${YELLOW}Wallet Description Operations:${NC}"
            echo "1. Set Description"
            echo "2. Show Description"
            read -r desc_choice
            case $desc_choice in
                1)
                    echo -e "${GREEN}Enter wallet description:${NC}"
                    read -r description
                    execute_command "set_description $description"
                    ;;
                2)
                    execute_command "get_description"
                    ;;
                *)
                    echo -e "${RED}Invalid option${NC}"
                    sleep 2
                    ;;
            esac
            ;;
        19)
            echo -e "${GREEN}Enter donation amount:${NC}"
            read -r donation_amount
            execute_command "donate $donation_amount"
            ;;
        20)
            execute_command "version"
            ;;
        0)
            echo -e "${GREEN}Goodbye!${NC}"
            execute_command "exit"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            sleep 2
            ;;
    esac
done 
