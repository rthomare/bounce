import { Heading, HStack } from '@chakra-ui/react';
import { Avatar } from './ui/avatar';

export function Navbar() {
  return (
    <HStack justifyContent="space-between" w="100%" p={4}>
      <Heading
        size="xl"
        fontWeight={'normal'}
        _hover={{ color: 'gray.600' }}
        transition="color 0.2s"
      >
        Bounce
      </Heading>
      <Avatar />
    </HStack>
  );
}
