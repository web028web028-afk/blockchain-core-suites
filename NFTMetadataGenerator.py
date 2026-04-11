import json
import random
from datetime import datetime

class NFTMetadataGenerator:
    def __init__(self):
        self.traits = {
            "background": ["Blue", "Purple", "Green", "Black", "White"],
            "body": ["Robot", "Human", "Alien", "Dragon", "Angel"],
            "weapon": ["Sword", "Shield", "Bow", "Staff", "Pistol"],
            "rarity": ["Common", "Uncommon", "Rare", "Epic", "Legendary"]
        }

    def generate_metadata(self, token_id: int, creator: str) -> dict:
        metadata = {
            "name": f"Genesis NFT #{token_id}",
            "description": "Unique blockchain genesis collection NFT",
            "image": f"ipfs://QmRandomHash{random.randint(100000, 999999)}",
            "external_url": "https://genesis-nft.io",
            "attributes": self._generate_attributes(),
            "creator": creator,
            "minted_at": int(datetime.now().timestamp()),
            "token_id": token_id
        }
        return metadata

    def _generate_attributes(self) -> list:
        attributes = []
        for trait_type, values in self.traits.items():
            value = random.choice(values)
            attributes.append({
                "trait_type": trait_type,
                "value": value
            })
        return attributes

    def save_metadata(self, token_id: int, metadata: dict, save_path: str = None):
        filename = save_path or f"nft_metadata_{token_id}.json"
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    generator = NFTMetadataGenerator()
    meta = generator.generate_metadata(1, "0xCreatorAddress")
    print(json.dumps(meta, indent=2))
