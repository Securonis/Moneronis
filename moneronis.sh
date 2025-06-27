#!/bin/bash


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

# Check if monero-wallet-cli is installed
if ! command -v monero-wallet-cli &> /dev/null; then
    echo -e "${RED}Error: monero-wallet-cli is not installed.${NC}"
    echo "Please install it first using: sudo apt-get install monero"
    exit 1
fi

# Function to display the main menu
show_menu() {
    clear
    echo -e "${GREEN}=== Monero Wallet Menu ===${NC}"
    echo -e "${YELLOW}1.${NC} Show Wallet Info"
    echo -e "${YELLOW}2.${NC} Show Balance"
    echo -e "${YELLOW}3.${NC} Show All Addresses"
    echo -e "${YELLOW}4.${NC} Create New Subaddress"
    echo -e "${YELLOW}5.${NC} Send XMR"
    echo -e "${YELLOW}6.${NC} Show Transactions"
    echo -e "${YELLOW}7.${NC} Sweep All Funds"
    echo -e "${YELLOW}8.${NC} Show Seed Words"
    echo -e "${YELLOW}9.${NC} Refresh Wallet"
    echo -e "${YELLOW}10.${NC} Check Wallet Status"
    echo -e "${YELLOW}11.${NC} Integrated Address Operations"
    echo -e "${YELLOW}12.${NC} Payment Verification"
    echo -e "${YELLOW}13.${NC} Transaction Key Management"
    echo -e "${YELLOW}14.${NC} Make Donation"
    echo -e "${YELLOW}15.${NC} Show Version"
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

# Function to execute monero-wallet-cli commands
execute_command() {
    echo "$1" | monero-wallet-cli
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

# Main loop
while true; do
    show_menu
    read -r choice

    case $choice in
        1)
            execute_command "wallet_info"
            ;;
        2)
            execute_command "balance"
            ;;
        3)
            execute_command "address all"
            ;;
        4)
            echo -e "${GREEN}Enter label for new subaddress (optional):${NC}"
            read -r label
            if [ -z "$label" ]; then
                execute_command "address new"
            else
                execute_command "address new $label"
            fi
            ;;
        5)
            echo -e "${GREEN}Enter destination address:${NC}"
            read -r address
            echo -e "${GREEN}Enter amount to send:${NC}"
            read -r amount
            execute_command "transfer $address $amount"
            ;;
        6)
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
        7)
            echo -e "${GREEN}Enter destination address for sweeping:${NC}"
            read -r sweep_address
            execute_command "sweep_all $sweep_address"
            ;;
        8)
            execute_command "seed"
            ;;
        9)
            execute_command "refresh"
            ;;
        10)
            execute_command "status"
            ;;
        11)
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
        12)
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
        13)
            echo -e "${GREEN}Enable transaction key storage? (y/n):${NC}"
            read -r enable_tx_key
            if [[ "$enable_tx_key" == "y" ]]; then
                execute_command "set store-tx-info 1"
                echo -e "${GREEN}Enter transaction ID to get key:${NC}"
                read -r txid
                execute_command "get_tx_key $txid"
            fi
            ;;
        14)
            echo -e "${GREEN}Enter donation amount:${NC}"
            read -r donation_amount
            execute_command "donate $donation_amount"
            ;;
        15)
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
