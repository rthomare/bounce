import { useState } from 'react';
import { BsGithub } from 'react-icons/bs';
import { TbHandLoveYou } from 'react-icons/tb';
import { FiSun } from 'react-icons/fi';
import { FaMoon } from 'react-icons/fa';
import { HStack, Icon, Text } from '@chakra-ui/react';
import { useColorMode } from '@/components/ui/color-mode';
import packageJson from '@/../package.json';

function ModeSwitcher() {
  const { colorMode, toggleColorMode } = useColorMode();
  const [hover, setHover] = useState(false);
  return (
    <HStack
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      onClick={toggleColorMode}
      _hover={{ color: 'gray.600' }}
      cursor="pointer"
    >
      <Icon
        as={colorMode === 'dark' ? FiSun : FaMoon}
        display="block"
        transition="color 0.6s"
      />
      <Text
        fontSize="small"
        p={0}
        m={0}
        style={{ transition: 'all 0.6s', maxWidth: hover ? 100 : 0 }}
        display="inline-block"
        overflow="hidden"
        whiteSpace="nowrap"
      >
        {colorMode === 'dark' ? 'light' : 'dark'} mode
      </Text>
    </HStack>
  );
}

function CodeLink() {
  const { version } = packageJson;
  const [hover, setHover] = useState(false);
  return (
    <HStack
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      onClick={() =>
        window.open('https://github.com/rthomare/rout3r', '_blank')
      }
      _hover={{ color: 'gray.600' }}
      cursor="pointer"
    >
      <Icon
        as={BsGithub}
        display="block"
        transition="color 0.6s"
        color={hover ? 'gray.600' : 'inherit'}
      />
      {/* animate text width on hover */}
      <Text
        fontSize="small"
        p={0}
        m={0}
        style={{ transition: 'all 0.6s', maxWidth: hover ? 200 : 0 }}
        display="inline-block"
        overflow="hidden"
        whiteSpace="nowrap"
        color={hover ? 'gray.600' : 'inherit'}
      >
        version {version}
      </Text>
    </HStack>
  );
}

function Donate() {
  const [hover, setHover] = useState(false);
  return (
    <HStack
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      onClick={() =>
        window.open(`https://www.buymeacoffee.com/rthomare`, '_blank')
      }
      _hover={{ color: 'gray.600' }}
      cursor="pointer"
    >
      <Icon
        as={TbHandLoveYou}
        display="inline"
        overflow="hidden"
        color={hover ? 'gray.600' : 'inherit'}
      />
      <Text
        fontSize="small"
        p={0}
        m={0}
        style={{ transition: 'all 0.6s', maxWidth: hover ? 100 : 0 }}
        display="inline-block"
        overflow="hidden"
        whiteSpace="nowrap"
        color={hover ? 'gray.600' : 'inherit'}
      >
        donate
      </Text>
    </HStack>
  );
}

export function Footer() {
  return (
    <HStack fontSize="lg" gap={4} color="GrayText">
      <Donate />
      <ModeSwitcher />
      <CodeLink />
    </HStack>
  );
}
